# frozen_string_literal: true

# FieldFormatter centralizes column-level conversions used by Service-layer formatters:
# decrypting encrypted_* columns with caller-specified defaults, and dereferencing
# constant labels by id.
class FieldFormatter
  TODO_LABEL = "TODO"

  def initialize(uhash:)
    @uhash = uhash
  end

  # Decrypt an encrypted_* column. Returns +default+ when the input is nil so callers
  # can pick the per-field empty representation (TODO_LABEL, "", nil, etc).
  def value(encrypted, default: nil)
    return default if encrypted.nil?

    @uhash.decrypt(encrypted)
  end

  # Look up a Constants entry by id and return its :label.
  # +constants_method+ is a Method object (e.g., Constants.method(:record_type)).
  def constant_label(constants_method, id)
    constants_method.call(id)&.dig(:label)
  end
end
