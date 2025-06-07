require "constants"
require "db/repositories"

module Service
  class View
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    def category_aggregation(begin_date: nil, end_date: nil)
      opts = { hashed_user_id: @hashed_uid, begin_date:, end_date: }.compact
      aggregated_records = DB::Repository::FinanceRecord.get_aggregated_by_category(**opts)
      
      aggregated_records.map do |aggregated_record|
        category = if aggregated_record[:encrypted_category].nil?
                     "未分類"
                   else
                     @uhash.decrypt(aggregated_record[:encrypted_category])
                   end

        # 各カテゴリのレコード詳細を取得
        detail_records = DB::Repository::FinanceRecord.get_records_by_category(
          hashed_user_id: @hashed_uid,
          category_id: aggregated_record[:category_id],
          begin_date: opts[:begin_date],
          end_date: opts[:end_date]
        )

        # レコード詳細をデコードして整形
        records = detail_records.map do |record|
          {
            id: record[:id],
            amount: record[:amount],
            description: record[:encrypted_description] ? @uhash.decrypt(record[:encrypted_description]) : "",
            date: record[:date],
            payment_method: record[:encrypted_payment_method] ? @uhash.decrypt(record[:encrypted_payment_method]) : nil,
            # Records::Recordエンティティ用の追加フィールド
            title: record[:encrypted_title] ? @uhash.decrypt(record[:encrypted_title]) : "",
            record_type: Constants.record_type(record[:record_type_id])[:label],
            state: Constants.record_state(record[:state_id])[:label],
            category: category,
            record_type_id: record[:record_type_id],
            state_id: record[:state_id],
            category_id: record[:category_id],
            payment_method_id: record[:payment_method_id]
          }
        end

        {
          category_id: aggregated_record[:category_id],
          category:,
          total_amount: aggregated_record[:total_amount],
          record_count: aggregated_record[:record_count],
          records: records
        }
      end
    end
  end
end