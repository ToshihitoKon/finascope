require "kaminari"
require "lib/user_hash"

module DB
  module Repository
    class FinanceRecord
      def self.model
        @model ||= DB::Model::FinanceRecord
      end
      private_class_method :model

      def self.get_page(
        hashed_user_id:,
        begin_date: Date.today.beginning_of_month,
        end_date: Date.today.end_of_month,
        page: 1, per_page: 50, sort: { created_at: :asc }
      )
        records = model.eager_load(:category, :payment_method)
                       .where(deleted_at: nil, date: begin_date..end_date, hashed_user_id:)
                       .order(sort).page(page).per(per_page)
        records.map do |record|
          model.to_dto(record).to_h.merge(
            {
              encrypted_category: record.category&.encrypted_label,
              encrypted_payment_method: record.payment_method&.encrypted_label
            }
          )
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end

      def self.update(id:, params:)
        record = model.where(id:).first
        return record if record.update(**params)

        raise Exceptions::InternalServerError.exception("failed to record update #{id}")
      end

      def self.delete(id:)
        return if model.soft_delete(where_clause: { id: }) > 0

        raise Exceptions::InternalServerError.exception("failed to record delete #{id}")
      end

      def self.get_aggregated_by_category(
        hashed_user_id:,
        begin_date: nil,
        end_date: nil
      )
        query = model.eager_load(:category)
                     .where(deleted_at: nil, hashed_user_id:)
        
        if begin_date && end_date
          query = query.where(date: begin_date..end_date)
        elsif begin_date
          query = query.where("date >= ?", begin_date)
        elsif end_date
          query = query.where("date <= ?", end_date)
        end

        query.group(:category_id)
             .select(
               :category_id,
               "categories.encrypted_label as encrypted_category",
               "SUM(amount) as total_amount",
               "COUNT(*) as record_count"
             )
             .map { |record|
               {
                 category_id: record.category_id,
                 encrypted_category: record.encrypted_category,
                 total_amount: record.total_amount.to_i,
                 record_count: record.record_count
               }
             }
      end
    end

    class Category
      def self.model
        @model ||= DB::Model::Category
      end
      private_class_method :model

      def self.all(hashed_user_id:)
        model.where(deleted_at: nil, hashed_user_id:).map do |record|
          model.to_dto(record).to_h
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end

      def self.update(id:, params:)
        record = model.where(id:).first
        return record if record.update(**params)

        raise Exceptions::InternalServerError.exception("failed to record update #{id}")
      end
    end

    class PaymentMethod
      def self.model
        @model ||= DB::Model::PaymentMethod
      end
      private_class_method :model

      def self.get(id:)
        model.where(deleted_at: nil, id:).first
      end

      def self.all(hashed_user_id:)
        model.where(deleted_at: nil, hashed_user_id:).map do |record|
          model.to_dto(record).to_h
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end

      def self.update(id:, params:)
        record = model.where(id:).first
        return record if record.update(**params)

        raise Exceptions::InternalServerError.exception("failed to record update #{id}")
      end
    end

    class InvoiceRecord
      def self.model
        @model ||= DB::Model::InvoiceRecord
      end
      private_class_method :model

      def self.all(hashed_user_id:)
        model.where(deleted_at: nil, hashed_user_id:).map do |record|
          model.to_dto(record).to_h
        end
      end

      def self.monthly_records(hashed_user_id:, year:, month:)
        records = model.eager_load(:payment_method)
                       .where(
                         deleted_at: nil,
                         hashed_user_id:,
                         withdrawal_date: Date.new(year, month)...Date.new(year, month).end_of_month
                       )
        records.map do |record|
          model.to_dto(record).to_h.merge(
            {
              payment_method: record.payment_method&.encrypted_label
            }
          )
        end
      end

      def self.create(dto)
        model.create(**dto.to_h)
      end

      def self.update(id:, params:)
        record = model.where(id:).first
        return record if record.update(**params)

        raise Exceptions::InternalServerError.exception("failed to record update #{id}")
      end

      def self.delete(id:)
        return if model.soft_delete(where_clause: { id: }) > 0

        raise Exceptions::InternalServerError.exception("failed to delete invoice record #{id}")
      end
    end
  end
end
