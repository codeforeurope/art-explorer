class CollectionItem < Hashie::Dash

  def self.index_type
    'collection_item'
  end

  def self.search(query, opts={})
    from = opts.fetch(:from, 0)
    size = opts.fetch(:size, 10)

    response = Elasticsearch.search(
      body: {
        from: from,
        size: size,
        query: {query_string: { query: query } }
      },
      type: index_type
    )
    response.results.map!{|r| CollectionItem.new(r._source)}
    response
  end

  property :irn, type: 'integer'
  property :accession_number
  property :first_name
  property :middle_name
  property :last_name
  property :suffix
  property :fullname
  property :organisation
  property :role
  property :accession_summary
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
  property :provenance
  property :bibliography

  property :tags
  property :content_tags
  property :subject_tags
end
