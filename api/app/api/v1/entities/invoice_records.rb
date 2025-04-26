module API
  module Entities
    class InvoiceRecords
      class InvoiceRecord < Grape::Entity
        expose :id, documentation: { type: Integer, desc: "InvoiceRecord ID" }
        expose :label, documentation: { type: String, desc: "InvoiceRecord label" }
        expose :payment_method, documentation: { type: String, desc: "Payment method used" }
        expose :withdrawal_day, documentation: { type: String, desc: "Withdrawal day. ISO8601" }
      end

      class PutResponse < Grape::Entity
        expose :status
        expose :id
      end
    end
  end
end
