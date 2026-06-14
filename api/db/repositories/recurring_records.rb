# frozen_string_literal: true

require_relative "mixins"

module DB
  module Repository
    class RecurringRecord
      extend Creatable
      extend Updatable
      extend SoftDeletable

      def self.model
        @model ||= DB::Model::RecurringRecord
      end
      private_class_method :model

      def self.with_encrypted_labels(record)
        model.to_dto(record).to_h.merge(
          encrypted_category: record.category&.encrypted_label,
          encrypted_payment_method: record.payment_method&.encrypted_label
        )
      end
      private_class_method :with_encrypted_labels

      def self.all(hashed_user_id:, year: nil, month: nil)
        scope = model.eager_load(:category, :payment_method)
                     .where(deleted_at: nil, hashed_user_id:)
        if year && month
          target_date = Date.new(year, month, 1)
          # start_date is on or before the target month
          scope = scope.where("start_date <= ?", target_date.end_of_month)
          # total_count is null (unlimited) OR months elapsed since start_date <= total_count
          # months elapsed = (year - start_year) * 12 + (month - start_month) + 1
          scope = scope.where(
            "total_count IS NULL OR (? - YEAR(start_date)) * 12 + (? - MONTH(start_date)) + 1 <= total_count",
            year, month
          )
        end
        scope.map { |r| with_encrypted_labels(r) }
      end

      def self.find(id:, hashed_user_id:)
        record = model.eager_load(:category, :payment_method)
                      .where(deleted_at: nil, id:, hashed_user_id:)
                      .first
        raise Exceptions::NotFound, "recurring record not found: #{id}" unless record

        with_encrypted_labels(record)
      end

      def self.generated_count(recurring_group_id:)
        DB::Model::FinanceRecord.where(deleted_at: nil, recurring_group_id:).count
      end
    end
  end
end
