class QueryBuilder
  class << self
    @@_TERM_FILTERS = [:type, :subject, :creator]
    @@_RANGE_FILTERS = [:earliest, :latest]

    def TERM_FILTERS
      @@_TERM_FILTERS
    end

    def RANGE_FILTERS
      @@_RANGE_FILTERS
    end
  end

  def initialize(opts)
    @query = opts.fetch(:query)
    @size = opts.fetch(:size)
    @from = opts.fetch(:from)
    @facets = opts.fetch(:facets, [])
    @term_filters = opts.fetch(:term_filters, {})
    @range_filters = opts.fetch(:range_filters, {})
    @sort = opts.fetch(:sort, :identifier)
    @sort_order = opts.fetch(:sort_order, :asc)
    @images = opts.fetch(:images, false)
  end

  def query
    query = {
      query: { bool: { should: [
        { query_string: { query: @query, default_operator: 'AND', default_field: 'type',        boost: 8 } },
        { query_string: { query: @query, default_operator: 'AND', default_field: 'subject',     boost: 8 } },
        { query_string: { query: @query, default_operator: 'AND', default_field: 'creator',     boost: 4 } },
        { query_string: { query: @query, default_operator: 'AND', default_field: 'title',       boost: 2 } },
        { query_string: { query: @query, default_operator: 'AND', default_field: 'description', boost: 1 } },
        { query_string: { query: @query, default_operator: 'AND', default_field: '_all',        boost: 0.5 } }
      ] } },
      from: @from,
      size: @size,
      sort: { @sort => { order: @sort_order }}
    }
    query[:facets] = facets if facets
    query[:filter] = filter if filter
    query
  end

  private

  def facets
    facets = @facets & QueryBuilder.TERM_FILTERS
    return unless facets.present?

    facets.reduce({}) do |memo, field|
      facet = { terms: { field: field_map(field), size: 100 } }
      facet[:facet_filter] = image_filter.first if image_filter # the image filter is special as it also applies to aggregate results
      memo[field] = facet
      memo
    end
  end

  def field_map(filter)
    f = {
      type: 'type.exact',
      creator: 'creator.exact'
    }[filter]
    f ||= filter.to_s
    f
  end

  def filter
    return unless (term_filters || range_filters || image_filter)

    must = []
    must.concat(term_filters) if term_filters
    must.concat(range_filters) if range_filters
    must.concat(image_filter) if image_filter
    { bool: { must: must } }
  end

  def term_filters
    return unless @term_filters.present?

    terms = @term_filters.reduce({}) do |memo, (field, value)|
      field = field_map(field.to_sym)
      memo[field] = value.split(',').map(&:strip)
      memo
    end
    [ { terms: terms } ]
  end

  def range_filters
    return unless @range_filters.present?

    earliest = @range_filters[:earliest]
    latest = @range_filters[:latest]

    ranges = []
    ranges << { range: { latest: { gte: earliest } } } if earliest.present?
    ranges << { range: { earliest: { lte: latest } } } if latest.present?
    ranges
  end

  def image_filter
    return unless @images
    [ { exists: { field: :images } } ]
  end
end
