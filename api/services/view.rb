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
      aggregated_records = DB::Repository::FinanceRecord.get_aggregated_by_category(**opts)

      aggregated_records.map do |aggregated_record|
        category = if aggregated_record[:category_id] == Constants::TODO_ID[:category] ||
                      aggregated_record[:encrypted_category].nil?
                     "TODO"
                   else
                     @uhash.decrypt(aggregated_record[:encrypted_category])
                   end

        actual_category_id = aggregated_record[:category_id] || Constants::TODO_ID[:category]

        detail_records = DB::Repository::FinanceRecord.get_records_by_category(
          hashed_user_id: @hashed_uid,
          category_id: actual_category_id,
          begin_date: opts[:begin_date],
          end_date: opts[:end_date]
        )

        records = detail_records.map { @formatter.format(it) }

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
