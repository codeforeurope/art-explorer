require 'yaml'
require './elasticsearch/collection_item'

module Elasticsearch
  def self.rack_env
    ENV['RACK_ENV'] || 'development'
  end

  def self.config
    YAML::load(File.read('./config/tire.yml'))[self.rack_env]
  end
end

Tire.configure { url Elasticsearch.config['url'] }