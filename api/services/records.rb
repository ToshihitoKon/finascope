require "db/repositories"
require "constants"

module Service
  module FinanceRecords
    def self.get_records(page: 1)
      records = DB::Repository::FinanceRecord.get_page(page: page, sort: { date: :asc })
      records.map do |record|
        {
          **record,
          record_type: Constants.record_types(record[:state_id])[:label]
        }
      end
    end
  end
end
