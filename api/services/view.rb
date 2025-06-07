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
      records = DB::Repository::FinanceRecord.get_aggregated_by_category(**opts)
      
      records.map do |record|
        category = if record[:encrypted_category].nil?
                     "未分類"
                   else
                     @uhash.decrypt(record[:encrypted_category])
                   end

        {
          category_id: record[:category_id],
          category:,
          total_amount: record[:total_amount],
          record_count: record[:record_count]
        }
      end
    end
  end
end