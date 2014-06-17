require 'logger'
require './collection_explorer'

require 'rack/cors'
require 'rack/contrib' # for JSONP
require 'raven'

logger = Logger.new('log/app.log')
use Rack::CommonLogger, logger

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :get
  end
end

Raven.configure do |config|
  config.dsn = 'https://ecdc1b58abd74399b193b07d37216a48:a7d54f934f134cf8a19b802f51e87662@app.getsentry.com/25245'
end
use Raven::Rack

map '/' do
  run Rack::Cascade.new [CollectionExplorer, DataAPI]
end
