require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './elasticsearch'

class SearchMethod < Poncho::JSONMethod
  param :q, :required => true
  param :p
  param :pp

  def invoke
    page = param(:p) || 1
    per_page = param(:pp) || 10
    response = CollectionItem.search(param(:q), page: page, per_page: per_page)
    
    {
      total: response.total,
      items: response.results.map(&:as_json)
    }
  end
end

class CollectionExplorer < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  get '/search',   &SearchMethod
end