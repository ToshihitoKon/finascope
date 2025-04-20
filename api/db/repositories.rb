require "kaminari"

module DB
  module Repository
    class FinanceRecord
      def self.model
        @model ||= DB::Model::FinanceRecord
      end

      def self.get_page(page:, per_page: 50, sort: { created_at: :asc })
        records = model.eager_load(:category, :payment_method)
                       .order(sort).page(page).per(per_page)
        records.map do |record|
          model.to_dto(record).to_h.merge(
            {
              category: record.category&.label,
              payment_method: record.payment_method&.label
            }
          )
        end
      end
    end
  end
end
