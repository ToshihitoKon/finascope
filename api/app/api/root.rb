# frozen_string_literal: true

require "grape"
require "lib/firebase"
require "grape-swagger"
require "grape-swagger-entity"
require_relative "./v1/root"

module API
  class Root < Grape::API
    format :json
    helpers do
      def authorization_header
        headers["Authorization"]
      end

      def request_bearer
        b = authorization_header&.gsub("Bearer ", "")
        return Constants::EXAMPLE_USER_UID if b.blank?

        b
      end

      def request_userdata
        jwt = authorization_header&.gsub("Bearer ", "")
        return { uid: Constants::EXAMPLE_USER_UID } if jwt.blank?

        begin
          Firebase.decode_jwt(jwt)
        rescue StandardError => e
          puts e.inspect
          error!({ error: "Invalid JWT", status: 401 }, 401)
        end
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
        API::Entities::View::CategoryAggregation
      ]
  end
end
