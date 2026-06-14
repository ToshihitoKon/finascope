# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "activerecord"
  gem "mysql2"
end
require "active_record"
require "mysql2"

require_relative "../db/connection"
require_relative "../db/models"
require_relative "../envs"

DB::Connection.establish

class SchemaMismatchException < StandardError; end

# https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
def schema_correct?(model_class)
  puts model_class.table_name

  begin
    model_class.first

    # pp build_create_table_definition(model_class.table_name)
    got = Set.new(model_class.column_names.map(&:to_sym))
    expect = DB::TableColumns.get_columns_set(model_class)
    if got != expect
      puts "Schema mismatch: #{expect.difference(got)}"
      return false
    end

    puts "Correct schema"
  rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError => e
    puts "Error: #{e}"
    return false
  end
  true
end

def confirm_destructive_operation(table_name)
  puts ""
  puts "WARNING: Destructive operation about to be performed!"
  puts "  Target host:     #{Envs::DB_HOST}:#{Envs::DB_PORT}"
  puts "  Target database: #{Envs::DB_NAME}"
  puts "  Table to drop and recreate: #{table_name}"
  puts ""
  puts "Type YES to confirm: "
  input = $stdin.gets&.chomp
  return if input == "YES"

  puts "Aborted. Input was not 'YES'."
  exit 1
end

def apply_table(model_class, force: false)
  table_name = model_class.table_name

  model_class.first
  got = Set.new(model_class.column_names.map(&:to_sym))
  expect = DB::TableColumns.get_columns_set(model_class)
  if got != expect
    p "got: #{got}"
    p "expect: #{expect}"
    raise SchemaMismatchException
  end
rescue SchemaMismatchException
  if force
    create_table table_name, id: false, force: true do |t|
      model_class.define_table_schema(t)
    end
  else
    pp "Schema mismatch: #{model_class.table_name}"
    pp "got: #{got}"
    pp "expect: #{expect}"
    raise
  end
rescue ActiveRecord::StatementInvalid => e
  pp "StatementInvalid for #{table_name}: #{e.message}"
  create_table table_name, id: false, if_not_exists: true do |t|
    model_class.define_table_schema(t)
  end
end

ActiveRecord::Schema.define do
  DB::Model::RECORD_MODELS.each do |model_class|
    unless schema_correct?(model_class)
      puts "Table '#{model_class.table_name}' needs to be created or recreated."
      confirm_destructive_operation(model_class.table_name)
      apply_table(model_class, force: true)
    end
    puts
  end
end
puts "End"
