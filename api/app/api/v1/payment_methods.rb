require "grape"
require "id"
require "models"

module API
  module V1
    class PaymentMethods < Grape::API
      resource :payment_methods do
        get do
          DB::Model::PaymentMethod.all
        end
      end
    end
  end
end
