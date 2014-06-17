require 'yaml'
require 'erb'

module Search
  def self.rack_env
    ENV['RACK_ENV'] || 'development'
  end

  def self.config
    YAML::load(ERB.new(File.read('./config/elasticsearch.yml')).result)[rack_env]
  end

  def self.client
    Elasticsearch::Client.new(host: Search.config['host'], trace: true, logger: DataAPI.logger)
    # Elasticsearch::Client.new(host: Search.config['host'])
  end

  def self.search(opts)
    type = opts.fetch(:type)
    body = opts.fetch(:body)

    response = client.search index: Search.config['index'], type: type, body: body
    mash = Hashie::Mash.new response
    Hashie::Mash.new(results: mash.hits.hits, total: mash.hits.total, facets: mash.facets)
  end

  def self.bulk_index(data, opts)
    type = opts.fetch(:type)
    id_field = opts.fetch(:id)

    base_opts = {
      _index: Search.config['index'],
      _type: type
    }
    body = data.map do |d|
      id = id_field ? d[id_field] : SecureRandom.uuid
      { index: base_opts.merge(_id: id, data: d)}
    end
    client.bulk body: body
  end

  def self.clear
    client.indices.delete index: Search.config['index'] rescue nil # ignore error if index doesn't exist
  end

  def self.create_index(opts={})
    body = opts.fetch(:body, {})
    client.indices.create index: Search.config['index'], body: body
  end

  def self.refresh
    client.indices.refresh index: Search.config['index']
  end
end
