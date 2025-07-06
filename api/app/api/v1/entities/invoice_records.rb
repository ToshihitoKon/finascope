# frozen_string_literal: true

require_relative 'records'

module API
  module Entities
    class InvoiceRecords
      class InvoiceRecord < Grape::Entity
        expose :id, documentation: { type: String, desc: 'InvoiceRecord ID' }
        expose :amount, documentation: { type: Integer, desc: 'InvoiceRecord amount' }
        expose :payment_method, documentation: { type: String, desc: 'Payment method used' }
        expose :payment_method_id, documentation: { type: String, desc: 'Payment method ID' }
        expose :withdrawal_date, documentation: { type: String, desc: 'Withdrawal date. ISO8601' }
        expose :state, documentation: { type: String, desc: 'State of the invoice record' }
        expose :state_id, documentation: { type: Integer, desc: 'State ID of the invoice record' }
      end

      class CategoryAggregation < Grape::Entity
        expose :category_id, documentation: { type: String, desc: 'Category ID' }
        expose :category, documentation: { type: String, desc: 'Category name' }
        expose :total_amount, documentation: { type: Integer, desc: 'Total amount for this category' }
        expose :begin_date, documentation: { type: String, desc: 'Aggregation period start date (ISO8601)' }
        expose :end_date, documentation: { type: String, desc: 'Aggregation period end date (ISO8601)' }
        expose :records, using: API::Entities::Records::Record, documentation: { type: Array, desc: 'Finance records in this category' }
      end

      class WithdrawalRecordsAggregation < Grape::Entity
        expose :payment_method_id, documentation: { type: String, desc: 'Payment method ID' }
        expose :payment_method, documentation: { type: String, desc: 'Payment method name' }
        expose :total_amount, documentation: { type: Integer, desc: 'Total amount for this payment method' }
        expose :begin_date, documentation: { type: String, desc: 'Aggregation period start date (ISO8601)' }
        expose :end_date, documentation: { type: String, desc: 'Aggregation period end date (ISO8601)' }
        expose :records, using: API::Entities::Records::Record, documentation: { type: Array, desc: 'Finance records for this payment method' }
      end
    end
  end
end
