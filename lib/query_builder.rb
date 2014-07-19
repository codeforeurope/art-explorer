class QueryBuilder
  class << self
    @@_TERM_FILTERS = [:type, :subject]
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
      query: { query_string: { query: @query } },
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

    facets.reduce({}) do |memo, filter|
      memo[filter] = { terms: { field: filter.to_s, size: 100 } }
      memo
    end
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
    [ { exists: { field: :images } }]
  end
end
