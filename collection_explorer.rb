require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './elasticsearch'

class DataAPI < Grape::API
  version 'v1', using: :header, vendor: 'manchesterartgallery'
  format :json

  desc 'Search the gallery collection'
  get '/search' do
    page = params.fetch(:p, 1).to_i
    size = params.fetch(:pp, 10).to_i
    from = (page-1) * size
    q = params.fetch(:q, '*')
    response = CollectionItem.search(q, from: from, size: size)

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
