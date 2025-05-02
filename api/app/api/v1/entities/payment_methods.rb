module API
  module Entities
    module PaymentMethods
      class PaymentMethod < Grape::Entity
        expose :id, documentation: { type: Integer, desc: "PaymentMethod ID" }
        expose :label, documentation: { type: String, desc: "PaymentMethod label" }
        expose :withdrawal_day_of_month, documentation: { type: Integer, desc: "Withdrawal day of month" }
      end

      class PutResponse < Grape::Entity
        expose :status
        expose :id
      end
    end
  end
end
