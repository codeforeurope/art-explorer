require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './collection_data'

namespace :data do
  desc "Import data from KE xml dump into elaticsearch"
  task :import do
    importer = CollectionData::Importer.new('all-data.xml')
    importer.import
  end

  desc "Clear data from elasticsearch"
  task :clear do
    CollectionData.clear
  end
end