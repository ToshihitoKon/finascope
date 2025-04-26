require "grape"
require "lib/id"
require "db/models"
require "services/payment_methods"

require_relative "entities/payment_methods"

module API
  module V1
    class PaymentMethods < Grape::API
      resource :payment_methods do
        get do
          payment_methods = Service::PaymentMethods.all
          present payment_methods,
                  with: API::Entities::PaymentMethods::PaymentMethod,
                  root: :payment_methods
        end

        put do
          params do
            requires :label, type: String, desc: "PaymentMethod label"
          end

          payment_method = Service::PaymentMethods.create(
            label: params[:label]
          )

          if payment_method
            status = "success"
          else
            status = "failed"
            status 422
          end
          resp = { status:, id: payment_method&.id }
          present resp, with: API::Entities::PaymentMethods::PutResponse
        end
      end
    end
  end
end
