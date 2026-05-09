# frozen_string_literal: true

require "constants"
require "lib/field_formatter"

class InvoiceRecordFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  # Build a flat monthly-record hash combining the (optional) invoice and its payment method.
  # The shape matches the API response for GET /invoice_records.
  def format_monthly(invoice:, payment_method:, calced_withdrawal_date:)
    {
      id: invoice&.dig(:id) || "",
      amount: invoice&.dig(:amount) || 0,
      withdrawal_date: invoice&.dig(:withdrawal_date) || calced_withdrawal_date,
      state: invoice ? FieldFormatter.constant_label(Constants.invoice_record_state(invoice[:state_id])) : "",
      state_id: invoice&.dig(:state_id) || 0,
      payment_method: FieldFormatter.label(payment_method[:encrypted_label], @uhash),
      payment_method_id: payment_method[:id]
    }
  end
end
