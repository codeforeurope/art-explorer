source 'https://rubygems.org'

gem 'sinatra'
gem 'grape'
gem 'elasticsearch'
gem 'patron'
gem 'hashie', git: 'https://github.com/intridea/hashie.git'
gem 'nokogiri'
gem 'rake'
gem 'data_smash'
gem 'activesupport'
gem 'rack-cors'
gem 'rack-contrib'
gem 'rubyzip', require: 'zip'
gem 'ruby-vips', require: 'vips'
gem 'sentry-raven'

group :development do
  gem 'grape_doc'
end

group :test do
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
end

group :development, :test do
  gem 'pry'
  gem 'binding_of_caller'
end

group :production do
  gem 'unicorn'
end
