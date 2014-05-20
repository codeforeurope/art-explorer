require 'spec_helper'

describe DataAPI do
  before do
    CollectionData::Importer.import('spec/support/example_data.xml')
    Search.refresh
  end

  let(:collection_item) { CollectionItem.find('1961.142') }

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

    context 'given a filter' do
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
  end

  describe 'GET /:id' do
    it 'should respond successfully' do
      puts "/item/#{collection_item.identifier}"
      get "/item/#{collection_item.identifier}"
      puts last_response.inspect
      last_response.status.should == 200
    end

    it 'should return the collection item as JSON' do
      get collection_item.identifier
      json = JSON.parse(last_response.body)
      json.should == collection_item
    end
  end
end
