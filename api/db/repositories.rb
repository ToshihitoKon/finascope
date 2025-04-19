require "active_record"
require "kaminari"

module DB
  module Repository
    class FinanceRecord
      def self.model
        @model ||= DB::Model::FinanceRecord
      end

      def self.find_by_id(id)
        record = model.find(id: id)
        model.to_dto(record)
      end

      def self.get_page(page:, per_page: 50, sort: { created_at: :asc })
        records = model.order(sort).page(page).per(per_page)
        model.array_to_dto(records)
      end
    end
  end
end
