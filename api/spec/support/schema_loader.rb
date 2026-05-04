# frozen_string_literal: true

require "active_record"
require "db/models"

module SchemaLoader
  def self.load!
    ActiveRecord::Schema.define do
      DB::Model::RECORD_MODELS.each do |model_class|
        create_table model_class.table_name, id: false, force: true do |t|
          model_class.define_table_schema(t)
        end
      end
    end
  end
end
