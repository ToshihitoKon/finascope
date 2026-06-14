# frozen_string_literal: true

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
        desc "Get Invoice Records",
             success: { model: API::Entities::InvoiceRecords::InvoiceRecord, is_array: true, as: :records }
        params do
          optional :year, type: Integer, desc: "(Integer) Target year"
          optional :month, type: Integer, desc: "(Integer) Target month"
        end
        get do
          if params[:year] && params[:month]
            year = params[:year].to_i
            month = params[:month].to_i
          else
            year = Date.today.year
            month = Date.today.month
          end

          uid = request_userdata[:uid]
          invoice_records_service = Service::InvoiceRecords.new(uid:)
          records = invoice_records_service.monthly_records(year:, month:)
          present records, with: API::Entities::InvoiceRecords::InvoiceRecord, root: :records
        end

        desc "Create an Invoice Record",
             entity: API::Entities::Common::Response
        params do
          requires :amount, type: Integer, desc: "(Integer) Invoice record amount"
          requires :state_id, type: Integer, desc: "(Integer) Invoice record state ID"
          requires :withdrawal_date, type: String, desc: "(String) Withdrawal date in ISO8601 format"
          requires :payment_method_id, type: String, desc: "(String) Payment method ID"
        end
        post do
          uid = request_userdata[:uid]
          invoice_records_service = Service::InvoiceRecords.new(uid:)
          record = invoice_records_service.create(
            amount: params[:amount],
            state_id: params[:state_id],
            withdrawal_date: Date.parse(params[:withdrawal_date]),
            payment_method_id: params[:payment_method_id]
          )
          present_mutation_response(record)
        end

        desc "Update an Invoice Record",
             entity: API::Entities::Common::Response
        params do
          requires :id, type: String, desc: "(String) Invoice record ID"
          requires :amount, type: Integer, desc: "(Integer) Invoice record amount"
          requires :state_id, type: Integer, desc: "(Integer) Invoice record state ID"
          requires :withdrawal_date, type: String, desc: "(String) Withdrawal date in ISO8601 format"
        end
        put ":id" do
          uid = request_userdata[:uid]
          invoice_records_service = Service::InvoiceRecords.new(uid:)
          record = invoice_records_service.update(
            id: params[:id],
            params: {
              amount: params[:amount],
              state_id: params[:state_id],
              payment_method_id: params[:payment_method_id],
              withdrawal_date: Date.parse(params[:withdrawal_date])
            }
          )
          present_mutation_response(record)
        end

        desc "Delete an Invoice Record",
             entity: API::Entities::Common::Response
        params do
          requires :id, type: String, desc: "(String) Invoice record ID"
        end
        delete ":id" do
          uid = request_userdata[:uid]
          Service::InvoiceRecords.new(uid:).delete( # NOTE: ダメなら exception が飛んでくる
            id: params[:id]
          )
          present_delete_response(params[:id])
        end

        desc "Get Withdrawal Records Aggregation",
             success: { model: API::Entities::InvoiceRecords::WithdrawalRecordsAggregation, as: :aggregation }
        params do
          requires :year, type: Integer, desc: "(Integer) Target year"
          requires :month, type: Integer, desc: "(Integer) Target month"
          requires :payment_method_id, type: String, desc: "(String) Payment method ID"
        end
        get :withdrawal_records_aggregation do
          uid = request_userdata[:uid]
          invoice_records_service = Service::InvoiceRecords.new(uid:)
          aggregation = invoice_records_service.withdrawal_records_aggregation(
            year: params[:year],
            month: params[:month],
            payment_method_id: params[:payment_method_id]
          )

          present aggregation, with: API::Entities::InvoiceRecords::WithdrawalRecordsAggregation, root: :aggregation
        end
      end
    end
  end
end
