ENV['RACK_ENV'] = 'test'

Bundler.require(:test)
require './collection_explorer'
require './collection_data'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) do
    CollectionData::Importer.clear_index
    CollectionData::Importer.create_index
  end

  def app
    DataAPI
  end
end
