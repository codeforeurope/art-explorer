require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './elasticsearch'

class DataAPI < Grape::API
  version 'v1', using: :header, vendor: 'manchesterartgallery'
  format :json

  desc 'Search the gallery collection'
  params do
    requires :q, type: String
    optional :p, :pp, type: String
  end

  get '/search' do
    page = params.fetch(:p, 1).to_i
    size = params.fetch(:pp, 10).to_i
    from = (page-1) * size
    q = params.fetch(:q)

    response = CollectionItem.search({
      from: from,
      size: size,
      query: { query_string: { query: q } }
    })

    {
      total: response.total,
      items: response.results
    }
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
