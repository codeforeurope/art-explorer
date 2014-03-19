require 'yaml'

module Search
  def self.rack_env
    ENV['RACK_ENV'] || 'development'
  end

  def self.config
    YAML::load(File.read('./config/tire.yml'))[rack_env]
  end

  def self.client
    # Elasticsearch::Client.new(host: Search.config['host'], trace: true, logger: DataAPI.logger)
    Elasticsearch::Client.new(host: Search.config['host'])
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

    base_opts = {
      _index: Search.config['index'],
      _type: type
    }
    client.bulk body: data.map{|d| { index: base_opts.merge(_id: SecureRandom.uuid, data: d)} }
  end

  def self.clear
    client.indices.delete index: Search.config['index'] rescue nil # ignore error if index doesn't exist
  end

  def self.create_index
    client.indices.create index: Search.config['index']
  end

  def self.refresh
    client.indices.refresh index: Search.config['index']
  end
end
