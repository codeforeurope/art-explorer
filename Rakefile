require 'rubygems'
require 'bundler'
Bundler.require(:default)
require './collection_data'
require './init/raven'

namespace :data do
  desc "Extract and import data from a KE data dump."
  task :import, :folder do |t, args|
    file = nil
    Dir.glob("#{args.folder}/*.zip") do |f|
      file = f
    end

    Raven.capture do
      CollectionData::Extracter.extract(file: file, out_path: 'public/assets/images')
      CollectionData::Importer.import('data.xml')
    end
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
