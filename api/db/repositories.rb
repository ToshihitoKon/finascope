# frozen_string_literal: true

require "kaminari"
require "lib/user_hash"

module DB
  module Repository
    class FinanceRecord
      def self.model
        @model ||= DB::Model::FinanceRecord
      end
      private_class_method :model

      # Invoice Records用の締め期間計算
      # payment_methodの締め日と引き落とし日を考慮して集計期間を算出
      # TODO: thinking calculate_closing_period は本当に Repository の責務か？
      def self.calculate_closing_period(year, month, closing_day_of_month, withdrawal_day_of_month)
        # パラメータの型変換
        year = year.to_i
        month = month.to_i
        closing_day_of_month = closing_day_of_month.to_i if closing_day_of_month
        withdrawal_day_of_month = withdrawal_day_of_month.to_i if withdrawal_day_of_month

        target_date = Date.new(year, month, 1)
        prev_prev_month = target_date.prev_month.prev_month
        prev_month = target_date.prev_month

        # 締め日なし（0）の場合は通常の月計算
        return [prev_month.beginning_of_month, prev_month.end_of_month] if closing_day_of_month.zero?

        # 月末締め（-1）の場合 → 月末締め翌月払い
        if closing_day_of_month == -1
          # 前々月1日〜前月末日
          return [prev_prev_month.beginning_of_month, prev_month.end_of_month]
        end

        # 通常の締め日（1-31）の場合
        if closing_day_of_month < withdrawal_day_of_month
          # 締め日が引き落とし日以前の場合(当月確定)
          # 前月(closing_day+1)〜当月closing_day
          begin_date = Date.new(year, month - 1, closing_day_of_month + 1)
          end_date = Date.new(year, month, closing_day_of_month)
        else
          # 締め日が引き落とし日以降の場合(当月未確定)
          # 前々月(closing_day+1)〜前月closing_day
          begin_date = Date.new(year, month - 2, closing_day_of_month + 1)
          end_date = Date.new(year, month - 1, closing_day_of_month)
        end

        [begin_date, end_date]
      rescue Date::Error
        # 日付エラーの場合は月末日で調整
        target_date = Date.new(year, month, 1)
        [target_date.beginning_of_month, target_date.end_of_month]
      end

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

        raise Exceptions::InternalServerError, "failed to record update #{id}"
      end

      def self.delete(id:)
        return if model.soft_delete(where_clause: { id: }).positive?

        raise Exceptions::InternalServerError, "failed to record delete #{id}"
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

        raise Exceptions::InternalServerError, "failed to record update #{id}"
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

        raise Exceptions::InternalServerError, "failed to record update #{id}"
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

        raise Exceptions::InternalServerError, "failed to record update #{id}"
      end

      def self.delete(id:)
        return if model.soft_delete(where_clause: { id: }).positive?

        raise Exceptions::InternalServerError, "failed to delete invoice record #{id}"
      end
    end
  end
end
