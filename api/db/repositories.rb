require "kaminari"

module DB
  module Repository
    class FinanceRecord
      def self.model
        @model ||= DB::Model::FinanceRecord
      end
      private_class_method :model

      def self.get_page(
        begin_date: Date.today.beginning_of_month,
        end_date: Date.today.end_of_month,
        page: 1, per_page: 50, sort: { created_at: :asc }
      )
        records = model.eager_load(:category, :payment_method)
                       .where(date: begin_date..end_date)
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

      def self.create(dto)
        model.create(**dto.to_h)
      end
    end

    class Category
      def self.model
        @model ||= DB::Model::Category
      end
      private_class_method :model

      def self.all
        model.all.map do |record|
          model.to_dto(record).to_h
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end
    end

    class PaymentMethod
      def self.model
        @model ||= DB::Model::PaymentMethod
      end
      private_class_method :model

      def self.all
        model.all.map do |record|
          model.to_dto(record).to_h
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end
    end

    class InvoiceRecord
      def self.model
        @model ||= DB::Model::InvoiceRecord
      end
      private_class_method :model

      def self.all
        model.all.map do |record|
          model.to_dto(record).to_h
        end
      end

      def self.monthly_records(year:, month:)
        model.eager_load(:payment_method)
             .where(
               withdrawal_date: Date.new(year, month)...Date.new(year, month).end_of_month
             ).map do |record|
          model.to_dto(record).to_h.merge(
            {
              payment_method: record.payment_method&.label
            }
          )
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end
    end
  end
end
