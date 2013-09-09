require 'spec_helper'

describe CollectionItem do
  let(:collection_item) { CollectionItem.search('*').results.first }

  before do 
    CollectionData::Importer.new('spec/support/example_data.xml').import
    CollectionItem.index.refresh
  end

  describe 'as_json' do
    it 'should not include the elasticsearch identifier' do
      collection_item.as_json.keys.should_not include('id')
    end
  end
end