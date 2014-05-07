require 'spec_helper'

describe CollectionItem do
  let(:query) { {
    query: {match_all: {}},
    facets: { medium: { terms: { field: 'medium' } } }
  } }
  let(:collection_item) { search_response.results.first }
  let(:search_response) { CollectionItem.search(query) }

  before do
    CollectionData::Importer.import('spec/support/example_data.xml')
    Search.refresh
  end

  describe '.search' do
    it 'should return results as CollectionItems' do
      collection_item.should be_a(CollectionItem)
    end

    it 'should return a total number of hits' do
      search_response.total.should == 1
    end

    it 'should include facets' do
      facets = search_response.facets
      facets[0].title.should == 'medium'
    end
  end

  context 'given a uid' do
    let(:uid) { 'abcd' }
    let(:tags) { ['foo', 'bar'] }
    let(:search_response) { CollectionItem.search(query, uid: uid) }

    before { Record.create(irn: '123456', uid: uid, tags: tags) }

    it 'should incorporate associated tags' do
      collection_item.tags.should == tags
    end
  end

  describe '.find' do
    it 'should return the record matching the given IRN' do
      CollectionItem.find('123456').should == collection_item
    end

    context 'given a non-existent IRN' do
      it 'should raise a RecordNotFound exception' do
        expect{ CollectionItem.find('098765') }.to raise_error(CollectionItem::RecordNotFound)
      end
    end

    context 'given a uid' do
      let(:irn) { '123456' }
      let(:uid) { 'abcd' }
      let(:tags) { ['foo', 'bar'] }

      before { Record.create(irn: irn, uid: uid, tags: tags) }

      it 'should incorporate associated tags' do
        CollectionItem.find(irn, uid: uid).tags.should == tags
      end
    end
  end

  describe '#tag' do
    let(:irn) { '123456' }
    let(:uid) { 'abcd' }
    let(:tags) { ['foo', 'bar'] }

    it 'should create a persistent set of tags' do
      collection_item.tag(uid, tags.join(','))
      CollectionItem.find(irn, uid: uid).tags.should == tags
    end
  end

  describe '#untag' do
    let(:irn) { '123456' }
    let(:uid) { 'abcd' }

    it 'should remove tags' do
      collection_item.untag(uid)
      CollectionItem.find(irn, uid: uid).tags.should be_nil
    end
  end
end
