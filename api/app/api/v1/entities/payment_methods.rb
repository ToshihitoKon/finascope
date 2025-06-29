module API
  module Entities
    module PaymentMethods
      class PaymentMethod < Grape::Entity
        expose :id, documentation: { type: String, desc: "PaymentMethod ID" }
        expose :label, documentation: { type: String, desc: "PaymentMethod label" }
        expose :withdrawal_day_of_month, documentation: { type: Integer, desc: "Withdrawal day of month" }
        expose :closing_day_of_month, documentation: { type: Integer, desc: "Closing day of month" }
      end
    end
  end
end
