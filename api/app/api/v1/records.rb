# frozen_string_literal: true

require "grape"
require "grape-entity"
require "date"

require "lib/id"
require "db/models"
require "services/records"

require_relative "entities/records"
require_relative "entities/common"

module API
  module V1
    class Records < Grape::API
      format :json

      resource :records do
        desc "Get Records",
             success: { model: API::Entities::Records::Record, is_array: true, as: :records }
        params do
          optional :page, type: Integer, desc: "(Integer) Page number for pagination"
          optional :begin_date, type: String, desc: "(String) Begin date in ISO8601 format"
          optional :end_date, type: String, desc: "(String) End date in ISO8601 format"
        end
        get do
          page = params[:page].to_i if params[:page]
          begin_date = Date.parse(params[:begin_date])&.beginning_of_day if params[:begin_date]
          end_date = Date.parse(params[:end_date])&.end_of_day if params[:end_date]

          uid = request_userdata[:uid]
          finance_records_service = Service::FinanceRecords.new(uid:)
          records = finance_records_service.get_records(page:, begin_date:, end_date:)
          present records, with: API::Entities::Records::Record, root: :records
        end

        desc "Create a Record",
             entity: API::Entities::CommonResponse
        params do
          requires :title, type: String, desc: "(String) Record title"
          requires :type_id, type: Integer, desc: "(Integer) Record type ID"
          requires :state_id, type: Integer, desc: "(Integer) Record state ID"
          requires :description, type: String, desc: "(String) Record description"
          requires :amount, type: Integer, desc: "(Integer) Record amount"
          requires :category_id, type: String, desc: "(String) Record category ID"
          requires :date, type: String, desc: "(String) Record date in ISO8601 format"
          requires :payment_method_id, type: String, desc: "(String) Payment method ID"
        end
        post do
          uid = request_userdata[:uid]
          finance_records_service = Service::FinanceRecords.new(uid:)
          record = finance_records_service.create(
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
          present resp, with: API::Entities::CommonResponse
        end

        desc "Update a Record",
             entity: API::Entities::CommonResponse
        params do
          requires :id, type: String, desc: "(String) Record ID"
          requires :title, type: String, desc: "(String) Record title"
          requires :type_id, type: Integer, desc: "(Integer) Record type ID"
          requires :state_id, type: Integer, desc: "(Integer) Record state ID"
          requires :description, type: String, desc: "(String) Record description"
          requires :amount, type: Integer, desc: "(Integer) Record amount"
          requires :category_id, type: String, desc: "(String) Record category ID"
          requires :date, type: String, desc: "(String) Record date in ISO8601 format"
          requires :payment_method_id, type: String, desc: "(String) Payment method ID"
        end
        put ":id" do
          uid = request_userdata[:uid]
          finance_records_service = Service::FinanceRecords.new(uid:)
          record = finance_records_service.update(
            id: params[:id],
            params: {
              title: params[:title],
              record_type_id: params[:type_id],
              state_id: params[:state_id],
              description: params[:description],
              amount: params[:amount],
              category_id: params[:category_id],
              date: Date.parse(params[:date]),
              payment_method_id: params[:payment_method_id]
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

        desc "Delete a Record",
             entity: API::Entities::CommonResponse
        params do
          requires :id, type: String, desc: "(String) Record ID"
        end
        delete ":id" do
          uid = request_userdata[:uid]
          finance_records_service = Service::FinanceRecords.new(uid:)
          finance_records_service.delete( # NOTE: ダメなら exception が飛んでくる
            id: params[:id]
          )

          status = "success"
          resp = { status:, id: params[:id] }
          present resp, with: API::Entities::CommonResponse
        end
      end
    end
  end
end
