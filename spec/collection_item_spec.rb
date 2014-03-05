require 'spec_helper'

describe CollectionItem do
  let(:collection_item) { CollectionItem.search('*').results.first }

  before do
    CollectionData::Importer.new('spec/support/example_data.xml').import
    Elasticsearch.refresh
  end

  describe '.search' do
    it 'should return results as CollectionItems' do
      results = CollectionItem.search('*').results
      results.first.should be_a(CollectionItem)
    end

    it 'should return a total number of hits' do
      CollectionItem.search('*').total.should == 1
    end

    context 'given a limit' do

    end
  end
end
