# frozen_string_literal: true

require "constants"
require "lib/field_formatter"

class FinanceRecordFormatter
  def initialize(uhash:)
    @field = FieldFormatter.new(uhash:)
  end

  def format(record)
    {
      **record,
      title: @field.value(record[:encrypted_title], default: ""),
      description: @field.value(record[:encrypted_description], default: ""),
      record_type: @field.constant_label(Constants.method(:record_type), record[:record_type_id]),
      state: @field.constant_label(Constants.method(:record_state), record[:state_id]),
      category: @field.value(record[:encrypted_category], default: FieldFormatter::TODO_LABEL),
      payment_method: @field.value(record[:encrypted_payment_method], default: FieldFormatter::TODO_LABEL)
    }
  end
end
