require "active_record"
require "kaminari"

module DB
  module Model
    class BaseWrapper < ActiveRecord::Base
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
    end
  end
end
