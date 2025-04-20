require "db/repositories"

module Service
  module FinanceRecords
    def self.get_records(page: 1)
      DB::Repository::FinanceRecord.get_page(page: page, sort: { date: :asc })
    end
  end
end
