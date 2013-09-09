require './collection_explorer'
require './collection_data'
Bundler.require(:test)

set :environment, :test

RSpec.configure do |rspec|
  rspec.include Rack::Test::Methods

  rspec.before(:all) do
    CollectionItem.index_name 'test-collection-items'
  end

  rspec.before(:each) do
    CollectionItem.index.delete rescue nil # might not be an index yet
    CollectionItem.index.create
  end

  def app
    CollectionExplorer
  end
end