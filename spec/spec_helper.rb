ENV['RACK_ENV'] = 'test'

Bundler.require(:test)
require './collection_explorer'
require './collection_data'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) do
    Search.clear
    Search.create_index
  end

  def app
    DataAPI
  end
end
