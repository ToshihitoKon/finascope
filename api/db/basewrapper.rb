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
        str = Struct.new(
          *columns,
          keyword_init: true
        ) do
          def valid?
            # とりあえず nil チェックだけ
            # TODO: NOT NULL だけコレにする
            is_valid = true
            members.each do |m|
              next if [:created_at, :updated_at, :deleted_at].include?(m)

              if self[m].nil?
                is_valid = false
                puts "Invalid: #{m} is nil" # TODO: logger にする
              end
            end
            is_valid
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
