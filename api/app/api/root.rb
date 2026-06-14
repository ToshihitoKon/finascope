# frozen_string_literal: true

require "grape"
require "lib/exceptions"
require "lib/firebase"
require "grape-swagger"
require "grape-swagger-entity"
require "services/recurring_records"
require_relative "v1/root"

module API
  class Root < Grape::API
    format :json

    rescue_from Exceptions::Base do |e|
      error!({ error: e.message, status: e.http_status }, e.http_status)
    end

    helpers do
      def authorization_header
        headers["Authorization"]
      end

      def request_userdata
        jwt = authorization_header&.gsub("Bearer ", "")
        if jwt.blank?
          raise Exceptions::Unauthorized, "Unauthorized" unless Envs::DEV_UID

          return { uid: Envs::DEV_UID }
        end

        # JWT failures raise Exceptions::Unauthorized / InternalServerError,
        # which rescue_from maps to the right HTTP status.
        userdata = Firebase.decode_jwt(jwt)
        Service::RecurringRecords.new(uid: userdata[:uid]).auto_generate_current_month
        userdata
      end

      # Present a create/update mutation result with Common::Response.
      # Truthy result -> success; falsy result -> HTTP 422 with failed status.
      # @param result [ActiveRecord::Base, nil, false] the Service return value
      def present_mutation_response(result)
        if result
          response_status = "success"
        else
          status 422
          response_status = "failed"
        end
        resp = { status: response_status, id: result&.id }
        present resp, with: API::Entities::Common::Response
      end

      # Present a delete result with Common::Response.
      # Delete failures are surfaced as exceptions by the Service layer,
      # so reaching here always means success.
      # @param id [String] the deleted resource ID
      def present_delete_response(id)
        resp = { status: "success", id: }
        present resp, with: API::Entities::Common::Response
      end
    end

    prefix :api
    mount API::V1::Root

    resource :healthcheck do
      get do
        { status: "healthy" }
      end
    end
  end

  class Documentation < Grape::API
    format :json
    mount API::Root
    add_swagger_documentation \
      models: [
        API::Entities::Categories::Category,
        API::Entities::Common::Response,
        API::Entities::InvoiceRecords::InvoiceRecord,
        API::Entities::InvoiceRecords::WithdrawalRecordsAggregation,
        API::Entities::PaymentMethods::PaymentMethod,
        API::Entities::Records::Record,
        API::Entities::RecurringRecords::RecurringRecord,
        API::Entities::View::CategoryAggregation
      ]
  end
end
