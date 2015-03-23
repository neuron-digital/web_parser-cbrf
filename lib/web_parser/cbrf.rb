require 'hpricot'
require 'hashie/mash'
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'

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

    # Обновление курса валют за последние day_count дней (включая завтрашний)
    # Данные извлекаются с cbr.ru
    #
    # @param day_count [Integer] param_desc
    # @return [Hash] результат загрузки
    #
    def exchange_rates(day_count = 7)
      date_start, date_finish = get_date_range_for_days(day_count)
      date_start_formatted = date_start.strftime('%d/%m/%Y')
      date_finish_formatted = date_finish.strftime('%d/%m/%Y')
      url_with_dates = RATES_DYNAMIC_URL_PATTERN.gsub('{date_start}', date_start_formatted).gsub('{date_finish}', date_finish_formatted)
      # Заполняем массив с аттриутами строк, для последующей записи в базу
      EXCHANGES.each.with_object(Hashie::Mash.new) do |(exchange_key, exchange_params), result|
        begin
          # Ссылка для получения курсов валют в указанном диапазоне дат
          url = url_with_dates.gsub('{currency_code}', exchange_params[:api_code])
          # Получаем распарсенный xml
          xml = Hpricot(open(url, &:read))
          # Упаковываем наборы аттрибутов, сгруппированные по датам (для удобства наполнения курсами сразу нескольких валют)
          (xml/:valcurs/:record).each do |item|
            # Пропускаем если отсутствует значение
            next if (value = (item/:value).first.try(:innerText).try(:gsub, ',', '.')).blank?
            date = Date.parse(item[:date])
            result[date] ||= {}
            record_attrs = result[date]
            # Добавляем к аттрибутам дату
            record_attrs[:date_at] ||= date
            # Добавляем к аттрибутам значание курса
            record_attrs[exchange_key] = value
          end
        rescue => e
          puts "Can't parse #{exchange_key} exchange rate"
          puts e.message
          puts e.backtrace
        ensure
          result
        end
      end
    rescue => e
      puts 'Parse error'
      puts e.message
      puts e.backtrace
      {}
    end

    # Возващает массив из двух дат
    # для диапазона day_count дней
    # @param [Fixnum] day_count
    # @return [Array[Date, Date]]
    #
    def get_date_range_for_days(day_count)
      [Date.today - (day_count.days - 2.days), Date.today + 1.day]
    end
  end
end