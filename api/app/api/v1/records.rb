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
          page = params[:page] ||= 1
          records = Service::FinanceRecords.get_records(page: page)
          present records, with: API::Entities::Records::Get, root: :records
        end
        put do
          params do
            requires :title, type: String, desc: "Record title"
            requires :typeId, type: Integer, desc: "Record type ID"
            requires :stateId, type: Integer, desc: "Record state ID"
            requires :description, type: String, desc: "Record description"
            requires :amount, type: Integer, desc: "Record amount"
            requires :categoryId, type: String, desc: "Record category ID"
            requires :date, type: String, desc: "Record date in ISO8601 format"
            require :paymentMethodId, type: String, desc: "Payment method ID"
          end

          # サービスクラスを使ってレコードを保存
          record = Service::FinanceRecords.create_record(
            title: params[:title],
            record_type_id: params[:typeId],
            state_id: params[:stateId],
            description: params[:description],
            amount: params[:amount],
            category_id: params[:categoryId],
            date: Date.parse(params[:date]),
            payment_method_id: params[:paymentMethodId]
          )

          if record
            { status: "success", record_id: record.id }
          else
            status 422
            { status: "error", message: "Failed to save record" }
          end
          { status: "success" }
        end
      end
    end
  end
end
