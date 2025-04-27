require "grape"
require_relative "./records"
require_relative "./categories"
require_relative "./payment_methods"
require_relative "./invoice_records"

module API
  module V1
    class Root < Grape::API
      format :json
      version "v1"

      mount API::V1::Records
      mount API::V1::Categories
      mount API::V1::PaymentMethods
      mount API::V1::InvoiceRecords

      resource :healthcheck do
        get do
          { status: "healthy" }
        end
      end
    end
  end
end
