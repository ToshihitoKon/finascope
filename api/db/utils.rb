require "active_record"
require "kaminari"

module DB
  class TableColumnsGenerator
    attr_reader :columns

    def self.get_columns_set(model_class)
      t = TableColumnsGenerator.new
      model_class.define_table_schema(t)
      t.columns
    end

    def initialize
      @columns = Set.new
    end

    def timestamps(*_args)
      @columns << :created_at
      @columns << :updated_at
    end

    def belongs_to(*_args); end
    def check_constraint(*_args); end
    def foreign_key(*_args); end
    def index(*_args); end
    def references(*_args); end
    def set_primary_key(*_args); end

    def column(name, *_args)
      @columns << name.to_sym
    end

    # ActiveRecord::Schema.define の t.string 等をキャッチする
    def method_missing(_method, name, *_args) # rubocop:disable Style/MissingRespondToMissing
      column(name)
    end
  end

  module Model
    class Base < ActiveRecord::Base
      self.abstract_class = true

      def self.dto
        return const_get("DTO") if const_defined?("DTO")

        columns = DB::TableColumnsGenerator.get_columns_set(self).to_a
        str = Struct.new(
          *columns,
          keyword_init: true
        )
        const_set("DTO", str)
      end

      # to_dto
      def self.to_dto(item)
        return nil unless item

        dto.new(
          **item.attributes.symbolize_keys
        )
      end

      def self.array_to_dto(records)
        records.map { |r| to_dto(r) }.compact
      end

      # Accessors
      def self.find_by_id(id)
        to_dto(find(id))
      end

      def self.get_page(page:, per_page: 50, sort: { created_at: :asc })
        array_to_dto(order(sort).page(page).per(per_page))
      end
    end
  end
end
