# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../", __dir__))

require "app/api/root"
require "db/connection"
require "lib/firebase"
require "database_cleaner/active_record"

require_relative "support/schema_loader"
require_relative "support/api_helper"
require_relative "support/auth_stub"

DB::Connection.establish

SchemaLoader.load!

RSpec.configure do |config|
  config.include ApiHelper
  config.include AuthStub

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
