# frozen_string_literal: true

require "kaminari"
require_relative "mixins"

module DB
  module Repository
    class FinanceRecord
      extend Creatable
      extend Updatable
      extend SoftDeletable

      def self.model
        @model ||= DB::Model::FinanceRecord
      end
      private_class_method :model

      # to_dto.to_h merged with the eager-loaded encrypted category/payment labels.
      def self.with_encrypted_labels(record)
        model.to_dto(record).to_h.merge(
          encrypted_category: record.category&.encrypted_label,
          encrypted_payment_method: record.payment_method&.encrypted_label
        )
      end
      private_class_method :with_encrypted_labels

      # Apply a begin/end date filter, where either bound is optional.
      def self.apply_date_range(query, begin_date:, end_date:)
        if begin_date && end_date
          query.where(date: begin_date..end_date)
        elsif begin_date
          query.where("date >= ?", begin_date)
        elsif end_date
          query.where("date <= ?", end_date)
        else
          query
        end
      end
      private_class_method :apply_date_range

      def self.get_page(
        hashed_user_id:,
        begin_date: Date.today.beginning_of_month,
        end_date: Date.today.end_of_month,
        page: 1, per_page: 50, sort: { created_at: :asc }
      )
        records = model.eager_load(:category, :payment_method)
                       .where(deleted_at: nil, date: begin_date..end_date, hashed_user_id:)
                       .order(sort).page(page).per(per_page)
        records.map { |record| with_encrypted_labels(record) }
      end

      def self.get_all_by_user(
        hashed_user_id:,
        begin_date: nil,
        end_date: nil
      )
        query = model.eager_load(:payment_method, :category)
                     .where(deleted_at: nil, hashed_user_id:)
        query = apply_date_range(query, begin_date:, end_date:)

        query.map { |record| with_encrypted_labels(record) }
      end

      # Invoice Records用：指定支払い方法の締め期間内すべてのレコードを取得
      def self.get_withdrawal_records_for_invoice(
        hashed_user_id:,
        year:,
        month:,
        payment_method_id:,
        begin_date:,
        end_date:
      )
        # 指定期間・支払い方法のすべてのレコードを取得
        query = model.eager_load(:payment_method, :category)
                     .where(
                       deleted_at: nil,
                       hashed_user_id:,
                       payment_method_id:,
                       date: begin_date..end_date
                     )

        query.map { |record| with_encrypted_labels(record) }
      end
    end
  end
end
