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

  desc 'Search the gallery collection'
  params do
    optional :q,   type: String,  desc: 'A valid search query', default: '*'
    optional :p,   type: Integer, desc: 'An optional page number'
    optional :pp,  type: Integer, desc: 'An optional page size'

    # filters
    QueryBuilder.FILTERS.each do |filter|
      optional filter, type: String
    end
  end
  get '/search' do
    q = params.fetch(:q)
    page = params.fetch(:p, 1)
    size = params.fetch(:pp, 10)
    from = (page-1) * size
    filters = params.slice(*QueryBuilder.FILTERS)

    builder = QueryBuilder.new({
      query: q,
      size: size,
      from: from,
      filters: filters
    })
    response = CollectionItem.search(builder.query)

    {
      total: response.total,
      items: response.results,
      facets: response.facets
    }
  end

  get %r{/item/[\d\/\.]+} do |id|
    puts "eyedeeee: #{id}"
    CollectionItem.find(id)
  end

  rescue_from CollectionItem::RecordNotFound do |e|
    Rack::Response.new([ e.message ], 400)
  end

  helpers do
    def collection_item!
      @collection_item = CollectionItem.find(params[:irn])
    end
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
