require "active_record"
require "kaminari"

require_relative "./BaseWrapper"
require_relative "./utils"

module DB
  module Model
    class FinanceRecord < DB::Model::BaseWrapper
      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(tbl)
        tbl.string :id, null: false, primary_key: true
        tbl.string :type_id, null: false
        tbl.text :title, null: false
        tbl.integer :amount, null: false
        tbl.string :category_id, null: false
        tbl.string :payment_method_id, null: false
        tbl.integer :state, null: false # 0: 未処理, 1: 処理中, 2: 完了
        tbl.date :date, null: false
        tbl.text :description, null: true

        tbl.timestamps null: false
      end
    end

    class Category < DB::Model::BaseWrapper
      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(tbl)
        tbl.string :id, null: false, primary_key: true
        tbl.string :label, null: false

        tbl.timestamps null: false
      end
    end

    class PaymentMethod < DB::Model::BaseWrapper
      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(tbl)
        tbl.string :id, null: false, primary_key: true
        tbl.string :label, null: false

        tbl.timestamps null: false
      end
    end
  end
end

module DB
  module Model
    RECORD_MODELS = [
      FinanceRecord,
      Category,
      PaymentMethod
    ].freeze
  end
end
