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
      end
    end
  end
end
