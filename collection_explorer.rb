require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'csv'

require 'active_support/core_ext/hash/slice'

require './lib/search'
require './lib/query_builder'
require './models/collection_item'
require './models/record'

Mongoid.load!(File.expand_path("config/mongoid.yml"))

class DataAPI < Grape::API
  use Rack::JSONP

  version 'v1', using: :header, vendor: 'manchesterartgallery'
  format :json

  logger Logger.new('log/app.log')

  desc 'Search the gallery collection'
  params do
    optional :q,   type: String,  desc: 'A valid search query', default: '*'
    optional :p,   type: Integer, desc: 'An optional page number'
    optional :pp,  type: Integer, desc: 'An optional page size'
    optional :uid, type: String,  desc: 'An optional unique identifier to retrieve tags'

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

    uid = params.fetch(:uid, nil)
    opts = uid ? {uid: uid} : {}

    builder = QueryBuilder.new({
      query: q,
      size: size,
      from: from,
      filters: filters
    })
    response = CollectionItem.search(builder.query, opts)

    {
      total: response.total,
      items: response.results,
      facets: response.facets
    }
  end

  get '/:irn' do
    CollectionItem.find(params[:irn])
  end

  rescue_from CollectionItem::RecordNotFound, Record::MalformedTags do |e|
    Rack::Response.new([ e.message ], 400)
  end

  helpers do
    def collection_item!
      @collection_item = CollectionItem.find(params[:irn])
    end
  end

  desc 'Attach a set of comma-separated tags to a collection item with given IRN'
  params do
    requires :uid,  type: String, desc: 'A unique identifier for you or your app'
    requires :tags, type: String, desc: 'A comma-separated list of tags e.g. foo,bar,baz'
  end
  post '/:irn/tags' do
    collection_item!
    @collection_item.tag(params[:uid], params[:tags])
  end

  desc 'Remove all tags from a collection item with given IRN'
  params do
    requires :uid,  type: String, desc: 'A unique identifier for you or your app'
  end
  delete '/:irn/tags' do
    collection_item!
    @collection_item.untag(params[:uid])
  end
end

class CollectionExplorer < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get '/' do
    'Ohai!'
  end
end
