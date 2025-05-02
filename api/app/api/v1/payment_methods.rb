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
          payment_methods_service = Service::PaymentMethods.new(uid: request_bearer)
          payment_methods = payment_methods_service.all
          present payment_methods,
                  with: API::Entities::PaymentMethods::PaymentMethod,
                  root: :payment_methods
        end

        put do
          params do
            requires :label, type: String, desc: "PaymentMethod label"
            requires :withdrawal_day_of_month, type: Integer, desc: "Withdrawal day of month"
          end

          payment_methods_service = Service::PaymentMethods.new(uid: request_bearer)
          payment_method = payment_methods_service.create(
            label: params[:label],
            withdrawal_day_of_month: params[:withdrawal_day_of_month]
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
