source 'https://rubygems.org'

gem 'sinatra'
gem 'grape'
gem 'elasticsearch'
gem 'hashie'
gem 'nokogiri'
gem 'rake'
gem 'data_smash', path: '../data_smash'
gem 'mongoid'
gem 'rack-cors'
gem 'rack-contrib'

group :development do
  gem 'grape_doc'
end

group :test do
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
  gem 'database_cleaner'
end

group :production do
  gem 'unicorn'
end
