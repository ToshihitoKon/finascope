require "constants"
require "db/repositories"
require "lib/id"

module Service
  class InvoiceRecords
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    def monthly_records(year: nil, month: nil)
      year ||= Date.today.year
      month ||= Date.today.month
      records = DB::Repository::InvoiceRecord
                .monthly_records(hashed_user_id: @hashed_uid, year:, month:)
      records.map do |record|
        {
          **record,
          state: Constants.invoice_record_state(record[:state_id])[:label]
        }
      end
    end

    def create(params)
      dto = DB::Model::InvoiceRecord.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        amount: params[:amount],
        payment_method_id: params[:payment_method_id],
        withdrawal_date: params[:withdrawal_date]
      )
      raise StandardError unless dto.valid?

      DB::Repository::InvoiceRecord.create(dto)
    end
  end
end
