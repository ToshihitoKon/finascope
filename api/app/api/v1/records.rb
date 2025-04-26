require "grape"
require "grape-entity"
require "date"

require "lib/id"
require "db/models"
require "services/records"

require_relative "entities/records"

module API
  module V1
    class Records < Grape::API
      format :json

      resource :records do
        get do
          page = params[:page] if params[:page]
          begin_date = Date.parse(params[:begin_date]) if params[:begin_date]
          end_date = Date.parse(params[:end_date]) if params[:end_date]

          records = Service::FinanceRecords.get_records(page:, begin_date:, end_date:)
          present records, with: API::Entities::Records::Record, root: :records
        end

        put do
          params do
            requires :title, type: String, desc: "Record title"
            requires :type_id, type: Integer, desc: "Record type ID"
            requires :state_id, type: Integer, desc: "Record state ID"
            requires :description, type: String, desc: "Record description"
            requires :amount, type: Integer, desc: "Record amount"
            requires :category_id, type: String, desc: "Record category ID"
            requires :date, type: String, desc: "Record date in ISO8601 format"
            require :payment_method_id, type: String, desc: "Payment method ID"
          end

          record = Service::FinanceRecords.create(
            title: params[:title],
            record_type_id: params[:type_id],
            state_id: params[:state_id],
            description: params[:description],
            amount: params[:amount],
            category_id: params[:category_id],
            date: Date.parse(params[:date]),
            payment_method_id: params[:payment_method_id]
          )

          if record
            status = "success"
          else
            status 422
            status = "failed"
          end

          resp = { status:, id: record&.id }
          present resp, with: API::Entities::Records::PutResponse
        end
      end
    end
  end
end
