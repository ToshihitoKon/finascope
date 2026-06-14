# frozen_string_literal: true

require "grape"
require "lib/id"
require "db/models"
require "services/recurring_records"

require_relative "entities/recurring_records"
require_relative "entities/common"

module API
  module V1
    class RecurringRecords < Grape::API
      format :json

      resource :recurring_records do
        desc "Get recurring records",
             success: { model: API::Entities::RecurringRecords::RecurringRecord, is_array: true, as: :recurring_records }
        get do
          uid = request_userdata[:uid]
          service = Service::RecurringRecords.new(uid:)
          records = service.get_all
          present records, with: API::Entities::RecurringRecords::RecurringRecord, root: :recurring_records
        end

        desc "Create a recurring record",
             entity: API::Entities::Common::Response
        params do
          requires :title,             type: String,  desc: "(String) Title"
          requires :type_id,           type: Integer, desc: "(Integer) Record type ID"
          requires :state_id,          type: Integer, desc: "(Integer) State ID"
          requires :description,       type: String,  desc: "(String) Description"
          requires :amount,            type: Integer, desc: "(Integer) Amount"
          requires :category_id,       type: String,  desc: "(String) Category ID"
          requires :payment_method_id, type: String,  desc: "(String) Payment method ID"
          requires :start_date,        type: String,  desc: "(String) Start date in ISO8601 format"
          optional :total_count,       type: Integer, desc: "(Integer) Total payment count (null: unlimited)"
        end
        post do
          uid = request_userdata[:uid]
          service = Service::RecurringRecords.new(uid:)
          record = service.create(
            title: params[:title],
            record_type_id: params[:type_id],
            state_id: params[:state_id],
            description: params[:description],
            amount: params[:amount],
            category_id: params[:category_id],
            payment_method_id: params[:payment_method_id],
            start_date: Date.parse(params[:start_date]),
            total_count: params[:total_count]
          )
          present_mutation_response(record)
        end

        desc "Update a recurring record",
             entity: API::Entities::Common::Response
        params do
          requires :id,                type: String,  desc: "(String) Recurring record ID"
          requires :title,             type: String,  desc: "(String) Title"
          requires :type_id,           type: Integer, desc: "(Integer) Record type ID"
          requires :state_id,          type: Integer, desc: "(Integer) State ID"
          requires :description,       type: String,  desc: "(String) Description"
          requires :amount,            type: Integer, desc: "(Integer) Amount"
          requires :category_id,       type: String,  desc: "(String) Category ID"
          requires :payment_method_id, type: String,  desc: "(String) Payment method ID"
          requires :start_date,        type: String,  desc: "(String) Start date in ISO8601 format"
          optional :total_count,       type: Integer, desc: "(Integer) Total payment count (null: unlimited)"
        end
        put ":id" do
          uid = request_userdata[:uid]
          service = Service::RecurringRecords.new(uid:)
          record = service.update(
            id: params[:id],
            params: {
              record_type_id: params[:type_id],
              state_id: params[:state_id],
              title: params[:title],
              amount: params[:amount],
              category_id: params[:category_id],
              payment_method_id: params[:payment_method_id],
              description: params[:description],
              start_date: Date.parse(params[:start_date]),
              total_count: params[:total_count]
            }
          )
          present_mutation_response(record)
        end

        desc "Delete a recurring record",
             entity: API::Entities::Common::Response
        params do
          requires :id, type: String, desc: "(String) Recurring record ID"
        end
        delete ":id" do
          uid = request_userdata[:uid]
          service = Service::RecurringRecords.new(uid:)
          service.delete(id: params[:id])
          present_delete_response(params[:id])
        end

        desc "Generate a finance record for a given month",
             entity: API::Entities::Common::Response
        params do
          requires :id,    type: String,  desc: "(String) Recurring record ID"
          requires :year,  type: Integer, desc: "(Integer) Year"
          requires :month, type: Integer, desc: "(Integer) Month"
        end
        post ":id/generate" do
          uid = request_userdata[:uid]
          service = Service::RecurringRecords.new(uid:)
          record = service.generate(
            id: params[:id],
            year: params[:year],
            month: params[:month]
          )
          present_mutation_response(record)
        end
      end
    end
  end
end
