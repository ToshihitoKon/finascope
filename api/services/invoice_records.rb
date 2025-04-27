require "constants"
require "db/repositories"
require "lib/id"

module Service
  module InvoiceRecords
    def self.monthly_records(year: nil, month: nil)
      year ||= Date.today.year
      month ||= Date.today.month
      DB::Repository::InvoiceRecord.monthly_records(year:, month:)
    end

    def self.create(params)
      dto = DB::Model::InvoiceRecord.dto.new(
        id: ID.generate,
        amount: params[:amount],
        payment_method_id: params[:payment_method_id],
        withdrawal_date: params[:withdrawal_date]
      )
      raise StandardError unless dto.valid?

      DB::Repository::InvoiceRecord.create(dto)
    end
  end
end
