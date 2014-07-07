require 'spec_helper'

describe DataAPI do
  before do
    CollectionData::Importer.import('spec/support/example_data.xml')
    Search.refresh
  end

  let(:collection_item) { CollectionItem.find('1961.142/1A') }

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
      facet['title'].should == 'type'
    end

    context 'given a page size' do
      before do
        # import again so we have two (identical) items
        CollectionData::Importer.import('spec/support/example_data.xml')
        Search.refresh
      end

      # FIXME
      # it 'should only return as many results as the page size' do
      #   get '/search', q: '*', pp: '1'
      #   json = JSON.parse(last_response.body)
      #   json['items'].size.should == 1
      # end
      #
      # it 'should still return the correct  total no. of results' do
      #   get '/search', q: '*', pp: '1'
      #   json = JSON.parse(last_response.body)
      #   json['total'].should == 2
      # end
    end

    context 'given a term filter' do
      it 'should return results matching the given filter' do
        get '/search', type: 'plaited'
        json = JSON.parse(last_response.body)
        json['total'].should == 1
      end

      it 'should not return results which do not match the given filter' do
        get '/search', type: 'welded'
        json = JSON.parse(last_response.body)
        json['total'].should == 0
      end
    end

    context 'given a range filter' do
      it 'should return results within the range' do
        get '/search', earliest: '1922', latest: '1922'
        json = JSON.parse(last_response.body)
        json['total'].should == 1
      end

      it 'should not return results within the range' do
        get '/search', earliest: '1918', latest: '1918'
        json = JSON.parse(last_response.body)
        json['total'].should == 0
      end
    end
  end

  describe 'GET /i/:id' do
    it 'should respond successfully' do
      get "/i/#{collection_item.identifier}"
      last_response.status.should == 200
    end

    it 'should return the collection item as JSON' do
      get "/i/#{collection_item.identifier}"
      json = JSON.parse(last_response.body)
      json.should == collection_item
    end

    context 'given a non-existent ID' do
      it 'should respond with a 404' do
        get '/i/1234.5678/9'
        last_response.status.should == 404
      end
    end
  end
end
