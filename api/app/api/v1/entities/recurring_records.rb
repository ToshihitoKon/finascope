# frozen_string_literal: true

module API
  module Entities
    module RecurringRecords
      class RecurringRecord < Grape::Entity
        format_with(:iso_date, &:iso8601)

        expose :id,               documentation: { type: String,  desc: "Recurring record ID" }
        expose :title,            documentation: { type: String,  desc: "Title" }
        expose :record_type, as: :type, documentation: { type: String, desc: "Type of record" }
        expose :amount,           documentation: { type: Integer, desc: "Amount" }
        expose :state,            documentation: { type: String,  desc: "State" }
        expose :category,         documentation: { type: String,  desc: "Category" }
        expose :payment_method,   documentation: { type: String,  desc: "Payment method" }
        expose :start_date, format_with: :iso_date, documentation: { type: String, desc: "Start date" }
        expose :end_date, documentation: { type: String, desc: "End date (null: unlimited, derived from total_count)" } do |r, _|
          r[:end_date]&.iso8601
        end
        expose :total_count,      documentation: { type: Integer, desc: "Total count (null: unlimited)" }
        expose :generated_count,  documentation: { type: Integer, desc: "Number of generated finance records" }
        expose :record_type_id,   documentation: { type: Integer, desc: "Record type ID" }
        expose :state_id,         documentation: { type: Integer, desc: "State ID" }
        expose :category_id,      documentation: { type: String,  desc: "Category ID" }
        expose :payment_method_id, documentation: { type: String, desc: "Payment method ID" }
      end
    end
  end
end
