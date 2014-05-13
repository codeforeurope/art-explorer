require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './collection_data'

namespace :data do
  desc "Extract data from a zip file containing data & images"
  task :extract, :file, :out_path do |t, args|
    args.with_defaults(file: 'data.zip', out_path: 'public/assets/images')
    CollectionData::Extracter.extract(file: args.file, out_path: args.out_path)
  end

  desc "Import data from KE xml dump into elaticsearch"
  task :import, :file do |t, args|
    args.with_defaults(file: 'data.xml')

    file = args.file
    CollectionData::Importer.import(file)
  end

  desc "Clear data from elasticsearch"
  task :clear do
    CollectionData::Importer.clear_index
  end

  desc "Create the elasticsearch index"
  task :create_index do
    CollectionData::Importer.create_index
  end
end
