require 'spec_helper'

describe CollectionItem do
  let(:search_response) { CollectionItem.search(query: {match_all: {}}) }

  before do
    CollectionData::Importer.new('spec/support/example_data.xml').import
    Elasticsearch.refresh
  end

  describe '.search' do
    it 'should return results as CollectionItems' do
      search_response.results.first.should be_a(CollectionItem)
    end

    it 'should return a total number of hits' do
      search_response.total.should == 1
    end
  end
end
