# frozen_string_literal: true

require "constants"
require "db/repositories"
require "lib/finance_record_formatter"
require "services/base"

module Service
  class View < Base
    def initialize(uid:)
      super
      @formatter = FinanceRecordFormatter.new(uhash: @uhash)
    end

    def category_aggregation(begin_date: nil, end_date: nil)
      opts = { hashed_user_id: @hashed_uid, begin_date:, end_date: }.compact
      all_records = DB::Repository::FinanceRecord.get_all_by_user(**opts)

      grouped = all_records.group_by do |r|
        r[:category_id] || Constants::TODO_ID[:category]
      end

      grouped.map do |category_id, records|
        sample = records.first
        category = if category_id == Constants::TODO_ID[:category] ||
                      sample[:encrypted_category].nil?
                     "TODO"
                   else
                     @uhash.decrypt(sample[:encrypted_category])
                   end

        {
          category_id:,
          category:,
          total_amount: records.sum { it[:amount] },
          record_count: records.size,
          records: records.map { @formatter.format(it) }
        }
      end
    end
  end
end
