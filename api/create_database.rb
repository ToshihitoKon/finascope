$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))

require "active_record"
require_relative "./db/connection"
require_relative "./db/models"

DB::Connection.establish

class SchemaMismatchException < StandardError; end

def apply_table(model_class)
  table_name = model_class.table_name

  model_class.first
  got = Set.new(model_class.column_names.map(&:to_sym))
  expect = DB::TableColumnsGenerator.get_columns_set(model_class)
  if got != expect
    p "got: #{got}"
    p "expect: #{expect}"
    raise SchemaMismatchException
  end
rescue SchemaMismatchException
  create_table table_name, id: false, force: true do |t|
    model_class.define_table_schema(t)
  end
rescue StandardError => e
  pp e
  create_table table_name, id: false, if_not_exists: true do |t|
    model_class.define_table_schema(t)
  end
end

ActiveRecord::Schema.define do
  DB::Model::RECORD_MODELS.each do |model_class|
    apply_table(model_class)
  end
end
pp "All Done"
