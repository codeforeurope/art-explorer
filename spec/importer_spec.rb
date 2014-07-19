require 'spec_helper'

describe CollectionData::Importer do
  describe '.import' do
    let(:filename) { 'spec/support/example_data.xml' }

    it 'should create a CollectionItem for each entry in the given data' do
      expect{ CollectionData::Importer.import(filename); Search.refresh }.to change{ CollectionItem.search(query: {match_all: {}}).total }.by(2)
    end

    it 'should populate elasticsearch from the given xml file' do
      CollectionData::Importer.import(filename)
      Search.refresh
      CollectionItem.search(query: {match: {irn: '123456'}}).should_not be_empty
    end

    context 'when the importer has already run once' do
      before { CollectionData::Importer.import(filename); Search.refresh }

      it 'should update entries rather than creating new ones' do
        expect{ CollectionData::Importer.import(filename); Search.refresh }.to change{ CollectionItem.search(query: {match_all: {}}).total }.by(0)
      end
    end
  end
end
