module API
  module Entities
    class InvoiceRecords
      class InvoiceRecord < Grape::Entity
        expose :id, documentation: { type: Integer, desc: "InvoiceRecord ID" }
        expose :amount, documentation: { type: Integer, desc: "InvoiceRecord amount" }
        expose :payment_method, documentation: { type: String, desc: "Payment method used" }
        expose :withdrawal_date, documentation: { type: String, desc: "Withdrawal date. ISO8601" }
        expose :state, documentation: { type: String, desc: "State of the invoice record" }
      end

      class PutResponse < Grape::Entity
        expose :status
        expose :id
      end
    end
  end
end
