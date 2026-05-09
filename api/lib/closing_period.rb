# frozen_string_literal: true

require "date"

module ClosingPeriod
  NO_CLOSING_DAY = 0
  END_OF_MONTH = -1

  # Computes the billing-cycle date range that a given withdrawal month covers,
  # based on the payment method's closing day and withdrawal day. Used to
  # aggregate finance_records into a single invoice for credit-card-like
  # payment methods.
  #
  # Returns [begin_date, end_date] (both inclusive) of the cycle whose
  # withdrawal falls in the given (year, month).
  #
  # closing_day_of_month conventions:
  #   0  -> no closing day; the cycle is the previous calendar month
  #   -1 -> end-of-month closing
  #   1..31 -> day of month at which the cycle closes
  #
  # When closing < withdrawal, the cycle ending in `month` is finalized and
  # withdrawn that same month (e.g. closing 15, withdrawal 27 ->
  # prev-month-16 .. this-month-15). Otherwise the withdrawal in `month`
  # settles the previous cycle (e.g. closing 27, withdrawal 10 ->
  # two-months-ago-28 .. prev-month-27).
  #
  # Falls back to the target month's full range when an invalid date is built
  # (e.g. closing_day 31 against a month with fewer days).
  def self.calculate(year:, month:, closing_day_of_month:, withdrawal_day_of_month:)
    year = year.to_i
    month = month.to_i
    closing_day_of_month = closing_day_of_month.to_i if closing_day_of_month
    withdrawal_day_of_month = withdrawal_day_of_month.to_i if withdrawal_day_of_month

    target_date = Date.new(year, month, 1)
    prev_prev_month = target_date.prev_month.prev_month
    prev_month = target_date.prev_month

    # No closing day: aggregate the entire previous month.
    return [prev_month.beginning_of_month, prev_month.end_of_month] if closing_day_of_month == NO_CLOSING_DAY

    # End-of-month closing: cycle runs from the first of two months ago to the last of the previous month.
    return [prev_prev_month.beginning_of_month, prev_month.end_of_month] if closing_day_of_month == END_OF_MONTH

    if closing_day_of_month < withdrawal_day_of_month
      # Cycle finalized in `month`: (closing_day + 1) prev-month .. closing_day this-month.
      begin_date = Date.new(year, month - 1, closing_day_of_month + 1)
      end_date = Date.new(year, month, closing_day_of_month)
    else
      # Cycle finalized in prev month: (closing_day + 1) two-months-ago .. closing_day prev-month.
      begin_date = Date.new(year, month - 2, closing_day_of_month + 1)
      end_date = Date.new(year, month - 1, closing_day_of_month)
    end

    [begin_date, end_date]
  rescue Date::Error
    target_date = Date.new(year, month, 1)
    [target_date.beginning_of_month, target_date.end_of_month]
  end
end
