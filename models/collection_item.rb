class CollectionItem < Hashie::Dash
  class RecordNotFound < StandardError;; end

  class << self

    def index_type
      'collection-item'
    end

    def index_mapping
      { 'collection-item' => { properties: {
        identifier: { type: :string, index: :not_analyzed },
        subject: { type: :string, index: :not_analyzed }
      } } }
    end

    def search(body)
      response = Search.search(body: body, type: index_type)
      response.results.map!{|r| CollectionItem.from_result(r) }
      reduce_facets!(response) if response.facets
      response
    end

    def find(accession_number)
      begin
        response = Search.get(accession_number, type: index_type)
        return CollectionItem.from_result(response)
      rescue Search::RecordNotFound => e
        raise RecordNotFound.new('Could not find the record with the given accession number')
      end
    end

    def from_result(result)
      CollectionItem.new(result._source)
    end

    def reduce_facets!(response)
      response.facets = response.facets.reduce([]) do |memo, (k,v)|
        memo << { title: k, terms: v.terms }
        memo
      end
    end
  end

  property :identifier    # accession no.
  property :description
  property :earliest
  property :latest
  property :format
  property :creator
  property :title
  property :type
  property :subject
  property :coverage      # just placename for now
  property :images        # an array of images
end
