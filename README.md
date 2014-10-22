## OauthLife

##### OauthLife - gem для получения информации о курсах валют с сайта ЦБРФ
---

### Установка

1\. Подключить гем в Gemfile

```ruby
gem 'web_parser-cbrf', git: 'git@git.nnbs.ru:gem/web_parser-cbrf.git', tag: 'v0.0.1'
```

В качестве тега, возможно, потребуется указать более свежую версию. Последняя версия на момент написания данного файла «v0.0.1»

2\. Выполнить команду в терминале 

```bash
$ bundle
```

### Использование

3\. Использование

Для получения курсов валют за 7 дней

```ruby
WebParser::Cbrf.exchange_rates
```

Для получения курсов за другое количество дней

```ruby
WebParser::Cbrf.exchange_rates(15) # за 15 дней
```

Для получения крайних дат (налало периода, конец периода) за указанное количество дней

```ruby
WebParser::Cbrf.get_date_range_for_days(5)
```

###### **This project rocks and uses MIT-LICENSE.**