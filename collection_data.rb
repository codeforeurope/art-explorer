require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './elasticsearch'

require './collection_data/importer'
require './collection_data/convertor'

module CollectionData
  def self.clear
    CollectionItem.index.delete
  end
end
