class CollectionItem < Hashie::Dash
  class RecordNotFound < StandardError;; end

  class << self

    def index_type
      'collection_item'
    end

    def index_mapping
      { collection_item: { properties: {
      }}}
    end

    def search(body)
      response = Search.search(body: body, type: index_type)
      response.results.map!{|r| CollectionItem.from_result(r) }
      reduce_facets!(response) if response.facets
      response
    end

    def find(accession_number)
      response = self.search({ query: { match: { identifier: accession_number }}})
      raise RecordNotFound.new('Could not find the record with the given accession number') if response.total != 1
      response.results.first
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
  property :date          # hash, incorporating start & end values
  property :description
  property :format
  property :creator
  property :title
  property :type
  property :subject
  property :coverage      # just placename for now
  property :images        # an array of images
end
