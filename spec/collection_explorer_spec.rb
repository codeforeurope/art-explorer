require 'spec_helper'

describe DataAPI do
  before do
    CollectionData::Importer.new('spec/support/example_data.xml').import
    Search.refresh
  end

  let(:collection_item) { CollectionItem.find('123456') }

  describe 'GET /search' do
    it 'should return the total no. of results' do
      get '/search', q: '*'
      json = JSON.parse(last_response.body)
      json['total'].should == 1
    end

    it 'should return the results as JSON' do
      get '/search', q: '*'
      json = JSON.parse(last_response.body)
      json['items'].first.should == collection_item
    end

    it 'should include facets' do
      get '/search', q: '*'
      json = JSON.parse(last_response.body)
      facet = json['facets'][0]
      facet['title'].should == 'medium'
    end

    context 'given a page size' do
      before do
        # import again so we have two (identical) items
        CollectionData::Importer.new('spec/support/example_data.xml').import
        Search.refresh
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

    context 'given an IRN with associated tags' do
      let(:uid) { 'abcd' }
      let(:tags) { ['foo', 'bar'] }
      before { Record.create(irn: collection_item.irn, uid: uid, tags: tags) }

      it 'should return the tags in the JSON response' do
        get '/search', q: '*', uid: uid
        json = JSON.parse(last_response.body)
        item = json['items'][0]
        item['tags'].should == tags
      end
    end
  end

  describe 'GET /:irn' do
    it 'should respond successfully' do
      get collection_item.irn
      last_response.status.should == 200
    end

    it 'should return the collection item as JSON' do
      get collection_item.irn
      json = JSON.parse(last_response.body)
      json.should == collection_item
    end
  end

  describe 'POST /:irn/tags' do
    let(:uid) { 'abcd' }
    let(:tags) { ['foo', 'bar', 'baz'] }
    it 'should respond successfully' do
      post "/#{ collection_item.irn }/tags", uid: uid, tags: tags.join(',')
      last_response.status.should == 201
    end

    it 'should create a set of tags for the collection_item in the database' do
      post "/#{ collection_item.irn }/tags", uid: 'abcd', tags: tags.join(',')
      record = Record.where(irn: collection_item.irn, uid: uid).first
      record.tags.should == tags
    end

    context 'given a non-existent irn' do
      it 'should 400' do
        post "/098765/tags", uid: 'abcd', tags: tags.join(',')
        last_response.status.should == 400
      end
    end

    context 'given a mangled set of tags' do
      it 'should 400' do
        post "/#{ collection_item.irn }/tags", uid: 'abcd', tags: 'foo, "bar", baz'
        last_response.status.should == 400
      end
    end

    context 'given a pre-existing set of tags' do
      before { Record.create(irn: collection_item.irn, uid: uid, tags: ['foo', 'bar']) }

      it 'should replace the tags' do
        post "/#{ collection_item.irn }/tags", uid: 'abcd', tags: tags.join(',')
        record = Record.where(irn: collection_item.irn, uid: uid).first
        record.tags.should == tags
      end
    end
  end

  describe 'DELETE /:irn/tags' do
    let(:uid) { 'abcd' }
    before { collection_item.tag(uid, 'foo,bar,baz') }

    it 'should remove any tags on the collection matching the given uid' do
      post "/#{ collection_item.irn }/tags", uid: uid
      collection_item.tags.should be_nil
    end
  end
end
