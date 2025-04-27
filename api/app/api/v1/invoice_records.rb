require "grape"
require "lib/id"
require "db/models"
require "services/invoice_records"

require_relative "entities/invoice_records"

module API
  module V1
    class InvoiceRecords < Grape::API
      resource :invoice_records do
        get do
          if params[:year] && params[:month]
            year = params[:year].to_i
            month = params[:month].to_i
          else
            year = Date.today.year
            month = Date.today.month
          end

          records = Service::InvoiceRecords.monthly_records(year:, month:)
          present records, with: API::Entities::InvoiceRecords::InvoiceRecord, root: :records
        end

        put do
          params do
            require :amount, type: Integer, desc: "Invoice record amount"
            require :payment_method_id, type: String, desc: "Payment method ID"
            require :withdrawal_date, type: String, desc: "Withdrawal date in ISO8601 format"
          end
        end
      end
    end
  end
end
