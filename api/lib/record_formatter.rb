# frozen_string_literal: true

require "constants"

class RecordFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  def format(record)
    # NOTE: nil encrypted_* fields mean the eager_load missed the association; treat as TODO.
    payment_method = if record[:encrypted_payment_method].nil?
                       "TODO"
                     else
                       @uhash.decrypt(record[:encrypted_payment_method])
                     end

    category = if record[:encrypted_category].nil?
                 "TODO"
               else
                 @uhash.decrypt(record[:encrypted_category])
               end

    {
      **record,
      title: record[:encrypted_title] ? @uhash.decrypt(record[:encrypted_title]) : "",
      description: record[:encrypted_description] ? @uhash.decrypt(record[:encrypted_description]) : "",
      record_type: Constants.record_type(record[:record_type_id])[:label],
      state: Constants.record_state(record[:state_id])[:label],
      category:,
      payment_method:
    }
  end
end
