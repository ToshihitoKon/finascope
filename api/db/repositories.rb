# frozen_string_literal: true

require "kaminari"
require "lib/exceptions"
require "lib/user_hash"

module DB
  module Repository
    # Shared mutation helpers extended onto repository classes.
    # Each module relies on the host class defining `self.model`.

    # Provides `create(dto)`.
    module Creatable
      def create(dto)
        model.create(**dto.to_h)
      end
    end

    # Provides `update(id:, params:)`.
    # Raises NotFound when the record is missing, InternalServerError on failure.
    module Updatable
      def update(id:, params:)
        record = model.where(id:).first
        raise Exceptions::NotFound, "record not found: #{id}" if record.nil?
        return record if record.update(**params)

        raise Exceptions::InternalServerError, "failed to record update #{id}"
      end
    end

    # Provides `delete(id:)` via soft delete. Raises NotFound when nothing matched.
    module SoftDeletable
      def delete(id:)
        return if model.soft_delete(where_clause: { id: }).positive?

        raise Exceptions::NotFound, "record not found: #{id}"
      end
    end

    class FinanceRecord
      extend Creatable
      extend Updatable
      extend SoftDeletable

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

      def self.get_aggregated_by_category(
        hashed_user_id:,
        begin_date: nil,
        end_date: nil
      )
        query = model.left_joins(:category)
                     .where(deleted_at: nil, hashed_user_id:)

        if begin_date && end_date
          query = query.where(date: begin_date..end_date)
        elsif begin_date
          query = query.where("date >= ?", begin_date)
        elsif end_date
          query = query.where("date <= ?", end_date)
        end

        query.group("finance_records.category_id")
             .select(
               "finance_records.category_id",
               "categories.encrypted_label as encrypted_category",
               "SUM(finance_records.amount) as total_amount",
               "COUNT(*) as record_count"
             )
             .map do |record|
               {
                 category_id: record.category_id,
                 encrypted_category: record.encrypted_category,
                 total_amount: record.total_amount.to_i,
                 record_count: record.record_count
               }
             end
      end

      def self.get_records_by_category(
        hashed_user_id:,
        category_id:,
        begin_date: nil,
        end_date: nil
      )
        query = model.eager_load(:payment_method, :category)
                     .where(deleted_at: nil, hashed_user_id:, category_id:)

        if begin_date && end_date
          query = query.where(date: begin_date..end_date)
        elsif begin_date
          query = query.where("date >= ?", begin_date)
        elsif end_date
          query = query.where("date <= ?", end_date)
        end

        query.map do |record|
          model.to_dto(record).to_h.merge(
            {
              encrypted_payment_method: record.payment_method&.encrypted_label,
              encrypted_category: record.category&.encrypted_label
            }
          )
        end
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

        query.map do |record|
          model.to_dto(record).to_h.merge(
            {
              encrypted_payment_method: record.payment_method&.encrypted_label,
              encrypted_category: record.category&.encrypted_label
            }
          )
        end
      end
    end

    class Category
      extend Creatable
      extend Updatable

      def self.model
        @model ||= DB::Model::Category
      end
      private_class_method :model

      def self.all(hashed_user_id:)
        model.where(deleted_at: nil, hashed_user_id:).map do |record|
          model.to_dto(record).to_h
        end
      end
    end

    class PaymentMethod
      extend Creatable
      extend Updatable

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
    end

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
