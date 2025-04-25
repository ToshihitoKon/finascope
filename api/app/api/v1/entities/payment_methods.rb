module API
  module Entities
    module PaymentMethods
      class PaymentMethod < Grape::Entity
        expose :id, documentation: { type: Integer, desc: "PaymentMethod ID" }
        expose :label, documentation: { type: String, desc: "PaymentMethod label" }
      end
    end
  end
end
