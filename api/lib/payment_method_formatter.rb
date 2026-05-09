# frozen_string_literal: true

require "lib/field_formatter"

class PaymentMethodFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  def format(record)
    {
      **record,
      label: FieldFormatter.label(record[:encrypted_label], @uhash)
    }
  end
end
