require "active_record"
require "id"
require "kaminari"

require_relative "./utils"

module DB
  module Model
    class Base < ActiveRecord::Base
      self.abstract_class = true

      def self.DTO
        return const_get("DTO") if const_defined?("DTO")

        columns = DB::TableColumnsGenerator.get_columns_set(self).to_a
        str = Struct.new(
          *columns,
          keyword_init: true
        )
        const_set("DTO", str)
      end

      # to_dto
      def self.to_dto(i)
        return nil unless i
        self.DTO.new(
          **i.attributes.symbolize_keys
        )
      end

      def self.array_to_dto(records)
        records.map{|r| self.to_dto(r)}.compact
      end

      # Accessors
      def self.findById(id)
        to_dto(self.find(id))
      end

      def self.get_page(page:, per_page: 50, sort: {created_at: :asc})
        self.array_to_dto(
                     self.order(sort).page(page).per(per_page)
        )
      end
    end

    class FinanceRecord < DB::Model::Base
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

    class Category < DB::Model::Base
      # define_table_schema: for ActiveRecord::Schema.define
      def self.define_table_schema(tbl)
        tbl.string :id, null: false, primary_key: true
        tbl.string :label, null: false

        tbl.timestamps null: false
      end
    end

    class PaymentMethod < DB::Model::Base
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
