require 'logger'
require './collection_explorer'

logger = Logger.new('log/app.log')
use Rack::CommonLogger, logger

map '/' do
  run CollectionExplorer
end