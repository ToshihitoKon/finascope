# frozen_string_literal: true

require "lib/field_formatter"

class PaymentMethodFormatter
  def initialize(uhash:)
    @field = FieldFormatter.new(uhash:)
  end

  def format(record)
    {
      **record,
      label: @field.value(record[:encrypted_label], default: FieldFormatter::TODO_LABEL)
    }
  end
end
