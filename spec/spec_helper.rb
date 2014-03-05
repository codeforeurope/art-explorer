require './collection_explorer'
require './collection_data'
Bundler.require(:test)

ENV['RACK_ENV'] = 'test'

RSpec.configure do |rspec|
  rspec.include Rack::Test::Methods

  rspec.before(:each) do
    Elasticsearch.clear
    Elasticsearch.create_index
  end

  def app
    DataAPI
  end
end
