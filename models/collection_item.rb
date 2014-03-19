class CollectionItem < Hashie::Dash
  class RecordNotFound < StandardError;; end

  class << self

    def index_type
      'collection_item'
    end

    def search(body, opts={})
      uid = opts.fetch(:uid, nil)

      response = Search.search(body: body, type: index_type)
      response.results.map!{|r| CollectionItem.from_result(r) }
      reduce_facets!(response) if response.facets
      add_tags!(response, uid) if uid
      response
    end

    def find(irn, opts={})
      response = self.search({ query: { match: { irn: irn }}}, opts)
      raise RecordNotFound.new('Could not find the record with the given IRN') if response.total != 1
      response.results.first
    end

    def from_result(result)
      CollectionItem.new(result._source)
    end

    def add_tags!(response, uid)
      irns = response.results.map(&:irn)
      records = Record.where(uid: uid).in(irn: irns)
      response.results.map! do |result|
        record = records.detect{|r| r.irn == result.irn}
        result.tags = record.tags if record
        result
      end
    end

    def reduce_facets!(response)
      response.facets = response.facets.reduce([]) do |memo, (k,v)|
        memo << { title: k, options: v.terms }
        memo
      end
    end
  end

  property :irn
  property :accession_number
  property :first_name
  property :middle_name
  property :last_name
  property :suffix
  property :fullname
  property :organisation
  property :role
  property :purchased
  property :created_on, type: 'integer'
  property :earliest_created_on, type: 'integer'
  property :latest_created_on, type: 'integer'
  property :object_name
  property :title
  property :series_title
  property :collection_title
  property :medium
  property :support
  property :physical_type
  property :height, type: 'double'
  property :width, type: 'double'
  property :unit
  property :description
  property :inscription
  property :bibliography

  property :tags
  property :content_tags
  property :subject_tags

  def tag(uid, tags_string)
    record = Record.find_or_create_by(irn: self.irn, uid: uid)
    record.update_tags(tags_string)
  end

  def untag(uid)
    Record.where(uid: uid).delete
  end
end
