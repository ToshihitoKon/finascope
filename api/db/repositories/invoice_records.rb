# frozen_string_literal: true

require_relative "mixins"

module DB
  module Repository
    class InvoiceRecord
      extend Creatable
      extend Updatable
      extend SoftDeletable

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
                         withdrawal_date: Date.new(year, month)..Date.new(year, month).end_of_month
                       )
        records.map do |record|
          model.to_dto(record).to_h.merge(
            {
              payment_method: record.payment_method&.encrypted_label
            }
          )
        end
      end
    end
  end
end
