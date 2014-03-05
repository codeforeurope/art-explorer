require 'spec_helper'

describe DataAPI do
  before do
    CollectionData::Importer.new('spec/support/example_data.xml').import
    Elasticsearch.refresh
  end

  it 'should return the total no. of results' do
    get '/search', q: '*'
    json = JSON.parse(last_response.body)
    json['total'].should == 1
  end

  it 'should return the results as JSON' do
    get '/search', q: '*'
    json = JSON.parse(last_response.body)
    json['items'].first.should == CollectionItem.search('*').results.first
  end

  context 'given a page size' do
    before do
      # import again so we have two (identical) items
      CollectionData::Importer.new('spec/support/example_data.xml').import
      Elasticsearch.refresh
    end

    it 'should only return as many results as the page size' do
      get '/search', q: '*', pp: '1'
      json = JSON.parse(last_response.body)
      json['items'].size.should == 1
    end

    it 'should still return the correct  total no. of results' do
      get '/search', q: '*', pp: '1'
      json = JSON.parse(last_response.body)
      json['total'].should == 2
    end
  end
end
