# frozen_string_literal: true

require "lib/exceptions"

module DB
  module Model
    # BaseWrapper
    # DTO を自動生成する
    # TODO: TableColumns を使っているので便利メソッド作れそう
    # TODO: NOT NULL を読んで Required/Optional 設定して、Validation できるようにする
    class BaseWrapper < ActiveRecord::Base
      self.abstract_class = true

      # soft_delete
      # @return deleted record num
      def self.soft_delete(where_clause:)
        records = where(where_clause)
        records.update_all(deleted_at: Time.current)
      end

      def self.dto
        return const_get("DTO") if const_defined?("DTO")

        columns = DB::TableColumns.get_columns_set(self).to_a
        nullable = DB::TableColumns.get_nullable_set(self)
        str = Struct.new(
          *columns,
          keyword_init: true
        ) do
          # Members that are nil and therefore fail validation.
          # Timestamp columns and nullable columns are exempt.
          define_method(:invalid_members) do
            exempt = [:created_at, :updated_at, :deleted_at] + nullable.to_a
            members.reject { |m| exempt.include?(m) || !self[m].nil? }
          end

          def valid?
            invalid_members.empty?
          end

          # Raises InvalidArgument listing the nil members when invalid.
          def validate!
            return if valid?

            raise Exceptions::InvalidArgument, "missing required fields: #{invalid_members.join(', ')}"
          end
        end
        const_set("DTO", str)
      end

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
