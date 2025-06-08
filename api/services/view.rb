require "constants"
require "db/repositories"
require_relative "records"

module Service
  class View
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
      @finance_records_service = Service::FinanceRecords.new(uid:)
    end

    def category_aggregation(begin_date: nil, end_date: nil)
      opts = { hashed_user_id: @hashed_uid, begin_date:, end_date: }.compact
      aggregated_records = DB::Repository::FinanceRecord.get_aggregated_by_category(**opts)
      
      aggregated_records.map do |aggregated_record|
        category = if aggregated_record[:category_id] == Constants::TODO_ID[:category] || aggregated_record[:encrypted_category].nil?
                     "TODO"
                   else
                     @uhash.decrypt(aggregated_record[:encrypted_category])
                   end

        # category_idがnilの場合はTODO項目として扱う
        actual_category_id = aggregated_record[:category_id] || Constants::TODO_ID[:category]

        # 各カテゴリのレコード詳細を取得
        detail_records = DB::Repository::FinanceRecord.get_records_by_category(
          hashed_user_id: @hashed_uid,
          category_id: actual_category_id,
          begin_date: opts[:begin_date],
          end_date: opts[:end_date]
        )

        # 共通のformat_recordメソッドを使用してレコード詳細をデコードして整形
        records = detail_records.map do |record|
          @finance_records_service.format_record(record)
        end

        {
          category_id: actual_category_id,
          category:,
          total_amount: aggregated_record[:total_amount],
          record_count: aggregated_record[:record_count],
          records: records
        }
      end
    end
  end
end