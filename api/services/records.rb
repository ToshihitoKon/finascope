require "constants"
require "db/repositories"
require "lib/id"

module Service
  module FinanceRecords
    def self.get_records(page: 1)
      records = DB::Repository::FinanceRecord.get_page(page: page, sort: { date: :asc })
      records.map do |record|
        {
          **record,
          record_type: Constants.record_type(record[:record_type_id])[:label],
          state: Constants.record_state(record[:state_id])[:label]
        }
      end
    end

    def self.create_record(params)
      dto = DB::Model::FinanceRecord.dto.new(
        id: ID.generate,
        record_type_id: params[:record_type_id],
        title: params[:title],
        amount: params[:amount],
        category_id: params[:category_id],
        payment_method_id: params[:payment_method_id],
        state_id: params[:state_id],
        date: params[:date],
        description: params[:description]
      )
      raise StandardError unless dto.valid? # TODO: ちゃんとした Exception を作る

      DB::Repository::FinanceRecord.create(dto)
    end
  end
end
