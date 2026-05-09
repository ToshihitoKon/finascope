# frozen_string_literal: true

# FieldFormatter centralizes column-level conversions used by Service-layer formatters:
# decrypting encrypted_* columns, applying TODO fallbacks, and dereferencing constant labels.
module FieldFormatter
  TODO_LABEL = "TODO"

  module_function

  # Decrypt label-like encrypted columns (encrypted_label / encrypted_category etc).
  # Returns TODO_LABEL when encrypted is nil so absent associations show as TODO.
  def label(encrypted, uhash)
    return TODO_LABEL if encrypted.nil?

    uhash.decrypt(encrypted)
  end

  # Decrypt free-text encrypted columns (encrypted_title / encrypted_description etc).
  # Returns nil when encrypted is nil; callers decide the empty representation.
  def text(encrypted, uhash)
    return nil if encrypted.nil?

    uhash.decrypt(encrypted)
  end

  # Extract the :label field from a Constants lookup result safely.
  def constant_label(constants_lookup_result)
    constants_lookup_result&.dig(:label)
  end
end
