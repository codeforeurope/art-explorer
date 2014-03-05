require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './collection_data'

namespace :data do
  desc "Import data from KE xml dump into elaticsearch"
  task :import, :file do |t, args|
    args.with_defaults(file: 'all-data.xml')

    file = args.file
    importer = CollectionData::Importer.new(file)
    importer.import
  end

  desc "Clear data from elasticsearch"
  task :clear do
    Elasticsearch.clear
  end
end
