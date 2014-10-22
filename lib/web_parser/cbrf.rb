require 'hpricot'
require 'hashie/mash'

module WebParser
  module Cbrf
    RATES_DYNAMIC_URL_PATTERN = 'http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1={date_start}&date_req2={date_finish}&VAL_NM_RQ={currency_code}'

    EXCHANGES = {
      usd: {
        api_code: 'R01235'
      },
      eur: {
        api_code: 'R01239'
      }
    }.freeze

    module_function

    # Обновление курса валют за последние day_count дней
    # Данные извлекаются с cbr.ru
    #
    # @param day_count [Integer] param_desc
    # @return [Hash] результат загрузки
    #
    def exchange_rates(day_count = 7)
      date_start, date_finish = get_date_range_for_days(day_count)
      date_start_formatted = I18n.l(date_start,  format: :exchange_rate_parser)
      date_finish_formatted = I18n.l(date_finish, format: :exchange_rate_parser)
      url_with_dates = RATES_DYNAMIC_URL_PATTERN.gsub('{date_start}', date_start_formatted).gsub('{date_finish}', date_finish_formatted)
      # Заполняем массив с аттриутами строк, для последующей записи в базу
      EXCHANGES.each.with_object({}) do |(exchange_key, exchange_params), result|
        # Ссылка для получения курсов валют в указанном диапазоне дат
        url = url_with_dates.gsub('{currency_code}', exchange_params[:api_code])
        # Получаем распарсенный xml
        xml = Hpricot(open(url, &:read))
        # Упаковываем наборы аттрибутов, сгруппированные по датам (для удобства наполнения курсами сразу нескольких валют)
        (xml/:valcurs/:record).each do |item|
          # Пропускаем если отсутствует значение
          next if (value = (item/:value).first.try(:innerText).try(:gsub, ',', '.')).blank?
          date = Date.parse(item[:date])
          record_attrs = (result[date] ||= {})
          # Добавляем к аттрибутам дату
          record_attrs[:date_at] ||= date
          # Добавляем к аттрибутам значание курса
          record_attrs[exchange_key] = value
        end
        result
      end
    end

    # Возващает массив из двух дат
    # для диапазона day_count дней
    # @param [Fixnum] day_count
    # @return [Array[Date, Date]]
    #
    def get_date_range_for_days(day_count)
      [Date.today - (day_count.days - 1.day), Date.today]
    end
  end
end