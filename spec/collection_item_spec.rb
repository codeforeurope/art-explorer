require 'spec_helper'

describe CollectionItem do
  before do
    CollectionData::Importer.import('spec/support/example_data.xml')
    Search.refresh
  end

  describe '.search' do
    let(:collection_item) { search_response.results.first }
    let(:search_response) { CollectionItem.search({
      query: { match_all: {}},
      facets: { medium: { terms: { field: 'medium' } } }
    }) }

    it 'should return results as CollectionItems' do
      collection_item.should be_a(CollectionItem)
    end

    it 'should return a total number of hits' do
      search_response.total.should == 2
    end

    it 'should include facets' do
      facets = search_response.facets
      facets[0].title.should == 'medium'
    end
  end

  describe '.find' do
    let(:identifier) { '1961.142/1A B/C' }

    it 'should return the record matching the given accession number' do
      CollectionItem.find(identifier).identifier == identifier
    end

    context 'given a non-existent IRN' do
      it 'should raise a RecordNotFound exception' do
        expect{ CollectionItem.find('1234.5678') }.to raise_error(CollectionItem::RecordNotFound)
      end
    end
  end
end
