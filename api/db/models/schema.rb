require "active_record"

class TableColumnsGenerator
  attr_reader :columns

  def self.get_columns_set ( model_class )
    t = TableColumnsGenerator.new
    model_class.define_table_schema(t)
    t.columns
  end

  def initialize
    @columns = Set.new
  end

  def timestamps(*args)
    @columns << "created_at"
    @columns << "updated_at"
  end
  # ActiveRecord::Schema.define の t.string 等をキャッチする
  def method_missing(type, name, *args)
    @columns << name.to_s
  end
end

class FinanceRecord < ActiveRecord::Base
  # define_table_schema: for ActiveRecord::Schema.define
  def self.define_table_schema(tbl)
    tbl.string :id, null: false, primary_key: true
    tbl.string :type_id, null: false
    tbl.text :title, null: false
    tbl.integer :amount, null: false
    tbl.string :category_id, null: false
    tbl.string :payment_method_id, null: false
    tbl.date :date, null: false
    tbl.text :description, null: true

    tbl.timestamps null: false
  end
end

class Category < ActiveRecord::Base
  # define_table_schema: for ActiveRecord::Schema.define
  def self.define_table_schema(tbl)
    tbl.string :id, null: false, primary_key: true
    tbl.string :label, null: false

    tbl.timestamps null: false
  end
end

class PaymentMethod < ActiveRecord::Base
  # define_table_schema: for ActiveRecord::Schema.define
  def self.define_table_schema(tbl)
    tbl.string :id, null: false, primary_key: true
    tbl.string :label, null: false

    tbl.timestamps null: false
  end
end

RECORD_MODELS = [
  FinanceRecord, 
  Category,
  PaymentMethod
].freeze
