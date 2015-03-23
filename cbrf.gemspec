$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'web_parser/cbrf/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'web_parser-cbrf'
  s.version     = WebParser::Cbrf::VERSION
  s.authors     = ['Go-Promo', 'Alexander Gorbunov']
  s.email       = %w(nmd@go-promo.ru lexgorbunov@gmail.com)
  s.homepage    = 'https://git.nnbs.ru/gem/web_parser-cbrf/tree/master'
  s.summary     = 'Parser of exchanges rates from cbrf.ru'
  s.description = 'Parser of exchanges rates from cbrf.ru'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 3.2.1'
  s.add_dependency 'hashie', '>= 3.3.1'
  s.add_dependency 'hpricot', '>= 0.8.6'
  s.add_dependency 'activesupport', '>= 4.2.0'
end
