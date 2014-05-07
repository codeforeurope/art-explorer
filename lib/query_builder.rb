class QueryBuilder
  class << self
    @@_FILTERS = [:medium]

    def FILTERS
      @@_FILTERS
    end
  end

  def initialize(opts)
    @query = opts.fetch(:query)
    @size = opts.fetch(:size)
    @from = opts.fetch(:from)
    @filters = opts.fetch(:filters, {})
  end

  def query
    query = {
      query: { query_string: { query: @query } },
      facets: facets,
      from: @from,
      size: @size
    }
    query[:filter] = filter if filter
    query
  end

  private

  def facets
    QueryBuilder.FILTERS.reduce({}) do |memo, filter|
      memo[filter] = { terms: { field: filter.to_s, size: 999 } }
      memo
    end
  end

  def filter
    return unless @filters.present?

    terms = @filters.reduce({}) do |memo, (field, value)|
      memo[field] = value.split(',').map(&:strip)
      memo
    end
    {terms: terms}
  end
end
