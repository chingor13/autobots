ENV['RAILS_ENV'] = 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'pp'

Rails.backtrace_cleaner.remove_silencers!

ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end
