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

    builder = QueryBuilder.new({
      query: q,
      size: size,
      from: from,
      term_filters: term_filters,
      range_filters: range_filters
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

puts DataAPI.routes.inspect

class CollectionExplorer < Sinatra::Base
  configure :production, :development do
    enable :logging
    set :base_url, 'http://data.manchestergalleries.asacalow.me'
  end

  get '/' do
    'Ohai!'
  end
end
