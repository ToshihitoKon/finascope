require "grape"
require "lib/id"
require "db/models"
require "services/invoice_records"

require_relative "entities/invoice_records"
require_relative "entities/common"

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

          invoice_records_service = Service::InvoiceRecords.new(uid: request_bearer)
          records = invoice_records_service.monthly_records(year:, month:)
          res = records.map do |record|
            withdrawal_date = record.dig(:invoice, :withdrawal_date) || record[:calced_withdrawal_date]
            {
              id: record.dig(:invoice, :id) || "",
              amount: record.dig(:invoice, :amount) || 0,
              withdrawal_date:,
              state: record.dig(:invoice, :state) || "",
              state_id: record.dig(:invoice, :state_id) || 0,
              payment_method: record.dig(:payment_method, :payment_method),
              payment_method_id: record.dig(:payment_method, :id) || ""
            }
          end
          present res, with: API::Entities::InvoiceRecords::InvoiceRecord, root: :records
        end

        post do
          params do
            require :amount, type: Integer, desc: "Invoice record amount"
            require :state_id, type: Integer, desc: "Invoice record state ID"
            require :withdrawal_date, type: String, desc: "Withdrawal date in ISO8601 format"
            require :payment_method_id, type: String, desc: "Payment method ID"
          end
          puts params.inspect

          invoice_records_service = Service::InvoiceRecords.new(uid: request_bearer)
          record = invoice_records_service.create(
            amount: params[:amount],
            state_id: params[:state_id],
            withdrawal_date: Date.parse(params[:withdrawal_date]),
            payment_method_id: params[:payment_method_id]
          )

          if record
            status = "success"
          else
            status = "failed"
            status 422
          end
          resp = { status:, id: record&.id }
          present resp, with: API::Entities::CommonResponse
        end

        put ":id" do
          params do
            require :id, type: Integer, desc: "Invoice record ID"
            require :amount, type: Integer, desc: "Invoice record amount"
            require :state_id, type: Integer, desc: "Invoice record state ID"
            require :withdrawal_date, type: String, desc: "Withdrawal date in ISO8601 format"
          end

          invoice_records_service = Service::InvoiceRecords.new(uid: request_bearer)
          record = invoice_records_service.update(
            id: params[:id],
            params: {
              amount: params[:amount],
              state_id: params[:state_id],
              payment_method_id: params[:payment_method_id],
              withdrawal_date: Date.parse(params[:withdrawal_date])
            }
          )

          if record.present?
            status = "success"
          else
            status = "failed"
            status 422
          end
          resp = { status:, id: record&.id }
          present resp, with: API::Entities::CommonResponse
        end
      end
    end
  end
end
