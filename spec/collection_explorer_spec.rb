require 'spec_helper'

describe CollectionExplorer do
  before do 
    CollectionData::Importer.new('spec/support/example_data.xml').import
    CollectionItem.index.refresh
  end

  it 'should return the total no. of results' do
    get '/search', q: '*'
    json = JSON.parse(last_response.body)
    json['total'].should ==1
  end

  it 'should return the results as JSON' do
    get '/search', q: '*'
    json = JSON.parse(last_response.body)
    json['items'].first.should == CollectionItem.search('*').results.first.as_json
  end
end