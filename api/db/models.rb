require "active_record"

require_relative "./BaseWrapper"
require_relative "./utils"

# NOTE: Relationship definitions document
# https://api.rubyonrails.org/v8.0/classes/ActiveRecord/Associations/ClassMethods

module DB
  module Model
    class FinanceRecord < DB::Model::BaseWrapper
      belongs_to :category
      belongs_to :payment_method

      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(t_def)
        t_def.string :id, null: false, primary_key: true
        t_def.integer :record_type_id, null: false
        t_def.integer :state_id, null: false
        t_def.text :title, null: false
        t_def.integer :amount, null: false
        t_def.string :category_id, null: false
        t_def.string :payment_method_id, null: false
        t_def.date :date, null: false
        t_def.text :description, null: true

        t_def.timestamps null: false
      end

      # TODO: add_index, remove_index に対応する
      def self.define_index
        [{}]
      end
    end

    class Category < DB::Model::BaseWrapper
      has_many :finance_record

      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(t_def)
        t_def.string :id, null: false, primary_key: true
        t_def.string :label, null: false

        t_def.timestamps null: false
      end
    end

    class PaymentMethod < DB::Model::BaseWrapper
      has_many :finance_record
      has_many :invoice_record

      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(t_def)
        t_def.string :id, null: false, primary_key: true
        t_def.string :label, null: false

        t_def.timestamps null: false
      end
    end

    class InvoiceRecord < DB::Model::BaseWrapper
      belongs_to :payment_method

      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(t_def)
        t_def.string :id, null: false, primary_key: true
        t_def.string :payment_method_id, null: false
        t_def.date :withdrawal_date, null: false
        t_def.integer :amount, null: false

        t_def.timestamps null: false
        # TODO: payment_method_id_withdrawal_day_index UNIQUE
      end
    end
  end
end

module DB
  module Model
    RECORD_MODELS = [
      FinanceRecord,
      Category,
      PaymentMethod,
      InvoiceRecord
    ].freeze
  end
end
