require 'autobots/version'
require 'active_support/all'
require 'active_model_serializers'
require 'bulk_cache_fetcher'

module Autobots
  autoload :ActiveRecordAssembler, 'autobots/active_record_assembler'
  autoload :Assembler, 'autobots/assembler'
  autoload :Helpers, 'autobots/helpers'
end
