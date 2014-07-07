require 'logger'
require './collection_explorer'
require 'rack/cors'
require 'rack/contrib' # for JSONP
require 'raven'
require './init/raven'

logger = Logger.new('log/app.log')
use Rack::CommonLogger, logger

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :get
  end
end

use Raven::Rack

map '/' do
  run Rack::Cascade.new [CollectionExplorer, DataAPI]
end
