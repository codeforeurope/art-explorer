require 'spec_helper'

describe DataAPI do
  before do
    CollectionData::Importer.import('spec/support/example_data.xml')
    Search.refresh
  end

  let(:collection_item) { CollectionItem.find('1961.142/1A B/C') }

  describe 'GET /search' do
    it 'should return the total no. of results' do
      get '/search', q: '*'
      json = JSON.parse(last_response.body)
      json['total'].should == 2
    end

    it 'should return the results as JSON' do
      get '/search', q: '*'
      json = JSON.parse(last_response.body)
      item = json['items'].first.symbolize_keys
      item.should =~ collection_item
    end

    it 'should not include facets by default' do
      get '/search', q: '*'
      json = JSON.parse(last_response.body)
      facet = json['facets'].should be_nil
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

    context 'given a field to facet on' do
      it 'should include the facet' do
        get '/search', q: '*', f: 'type'
        json = JSON.parse(last_response.body)
        facet = json['facets'][0]
        facet['title'].should == 'type'
      end
    end

    context 'given an artist name to facet on' do
      it 'should include the full name in the facet' do
        get '/search', q: '*', f: 'creator'
        json = JSON.parse(last_response.body)
        facet = json['facets'][0]
        facet['terms'].first['term'].should == 'Sir John Doe'
      end
    end

    context 'given a term filter' do
      it 'should return results matching the given filter' do
        get '/search', type: 'plaited'
        json = JSON.parse(last_response.body)
        json['total'].should == 2
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
        json['total'].should == 2
      end

      it 'should not return results within the range' do
        get '/search', earliest: '1918', latest: '1918'
        json = JSON.parse(last_response.body)
        json['total'].should == 0
      end
    end

    context 'given images=true' do
      it 'should filter out results which do not have an image' do
        get '/search', q: '*', i: 'true'
        json = JSON.parse(last_response.body)
        json['total'].should == 1
      end
    end

    context 'given a sort field and order' do
      it 'should sort the results by the given field' do
        get '/search', q: '*', s: 'earliest', so: 'desc'
        json = JSON.parse(last_response.body)
        json['items'].map{|i| i['earliest']}.should == [1921, 1920]
      end
    end
  end

  describe 'GET /i/:id' do
    let(:id) { URI.encode(collection_item.identifier) }

    it 'should respond successfully' do
      get "/i/#{id}"
      last_response.status.should == 200
    end

    it 'should return the collection item as JSON' do
      get "/i/#{id}"
      json = JSON.parse(last_response.body)
      json.symbolize_keys!
      json.should =~ collection_item
    end

    context 'given a non-existent ID' do
      it 'should respond with a 404' do
        get '/i/1234.5678/9'
        last_response.status.should == 404
      end
    end
  end
end
