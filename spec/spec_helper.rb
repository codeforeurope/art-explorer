ENV['RACK_ENV'] = 'test'

Bundler.require(:test)
require './collection_explorer'
require './collection_data'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    Search.clear
    Search.create_index

    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  def app
    DataAPI
  end
end
