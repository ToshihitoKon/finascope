module API
  module Entities
    module Records
      class Record < Grape::Entity
        format_with(:iso_timestamp, &:iso8601)

        expose :id, documentation: { type: Integer, desc: "Record ID" }
        expose :record_type, as: :type, documentation: { type: String, desc: "Type of record" }
        expose :title, documentation: { type: String, desc: "Title of record" }
        expose :amount, documentation: { type: Integer, desc: "Amount of record" }
        expose :state, documentation: { type: String, desc: "State of record" }
        expose :category, documentation: { type: String, desc: "Category of record" }
        expose :payment_method, documentation: { type: String, desc: "Payment method used" }
        expose :date, format_with: :iso_timestamp, documentation: { type: String, desc: "Date of record" }
        expose :description, documentation: { type: String, desc: "Description of record" }
      end
    end
  end
end
