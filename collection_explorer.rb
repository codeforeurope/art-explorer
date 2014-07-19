require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'csv'

require 'active_support/core_ext/hash/slice'

require './lib/search'
require './lib/query_builder'
require './models/collection_item'

class DataAPI < Grape::API
  use Rack::JSONP

  version 'v1', using: :header, vendor: 'manchestergalleries'
  format :json

  logger Logger.new('log/app.log')

  desc 'Search the gallery collection.'
  params do
    optional :q,   type: String,  desc: 'A valid search query', default: '*'
    optional :p,   type: Integer, desc: 'An optional page number'
    optional :pp,  type: Integer, desc: 'An optional page size'
    optional :f,   type: String,  desc: 'An optional set of comma-separated fields to facet on'
    optional :s,   type: String,  desc: 'A field to sort on'
    optional :so,  type: String,  desc: "Order in which to sort – either 'asc' or 'desc'"
    optional :i,   type: Boolean, desc: "Set to 'true' to return records with images only"

    # filters
    (QueryBuilder.TERM_FILTERS && QueryBuilder.RANGE_FILTERS).each do |filter|
      optional filter, type: String
    end
  end
  get '/search' do
    q = params.fetch(:q)
    page = params.fetch(:p, 1)
    size = params.fetch(:pp, 10)
    from = (page-1) * size
    term_filters = params.slice(*QueryBuilder.TERM_FILTERS)
    range_filters = params.slice(*QueryBuilder.RANGE_FILTERS)
    facets = params.fetch(:f, '').split(',').map(&:strip).map(&:to_sym)
    images = params.fetch(:i, false)
    sort = params.fetch(:s, :identifier)
    sort_order = params.fetch(:so, :asc)

    builder = QueryBuilder.new({
      query: q,
      size: size,
      from: from,
      term_filters: term_filters,
      range_filters: range_filters,
      facets: facets,
      sort: sort,
      sort_order: sort_order,
      images: images
    })
    response = CollectionItem.search(builder.query)

    {
      total: response.total,
      items: response.results,
      facets: response.facets
    }
  end

  rescue_from CollectionItem::RecordNotFound do |e|
    Rack::Response.new([ e.message ], 404)
  end

  desc 'Get an individual record.'
  params do
    requires :id, type: String, desc: 'The accession number of the record'
  end
  get '/i/:id', requirements: {id: /[\w\/\.]+/} do
    id = params[:id]
    CollectionItem.find(id)
  end
end

class CollectionExplorer < Sinatra::Base
  configure :production, :development do
    enable :logging
    set :base_url, 'http://data.manchestergalleries.asacalow.me'
  end

  get '/' do
    'Ohai!'
  end
end
