$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))

require "active_record"
require_relative "../db/connection"
require_relative "../db/models"

DB::Connection.establish

class SchemaMismatchException < StandardError; end

# https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
def check_schema(model_class)
  puts model_class.table_name

  begin
    model_class.first

    # pp build_create_table_definition(model_class.table_name)
    got = Set.new(model_class.column_names.map(&:to_sym))
    expect = DB::TableColumns.get_columns_set(model_class)
    if got != expect
      puts "Schema mismatch: #{expect.difference(got)}"
      return
    end

    puts "Correct schema"
  rescue StandardError => e
    puts "Error: #{e}"
    nil
  end
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
rescue StandardError => e
  pp e
  create_table table_name, id: false, if_not_exists: true do |t|
    model_class.define_table_schema(t)
  end
end

ActiveRecord::Schema.define do
  DB::Model::RECORD_MODELS.each do |model_class|
    check_schema(model_class)
    apply_table(model_class, force: true)
    puts
  end
end
puts "End"
