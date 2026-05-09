# frozen_string_literal: true

require "constants"
require "lib/field_formatter"

class FinanceRecordFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  def format(record)
    {
      **record,
      title: FieldFormatter.text(record[:encrypted_title], @uhash) || "",
      description: FieldFormatter.text(record[:encrypted_description], @uhash) || "",
      record_type: FieldFormatter.constant_label(Constants.record_type(record[:record_type_id])),
      state: FieldFormatter.constant_label(Constants.record_state(record[:state_id])),
      category: FieldFormatter.label(record[:encrypted_category], @uhash),
      payment_method: FieldFormatter.label(record[:encrypted_payment_method], @uhash)
    }
  end
end
