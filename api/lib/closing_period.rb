# frozen_string_literal: true

require "date"

module ClosingPeriod
  NO_CLOSING_DAY = 0
  END_OF_MONTH = -1

  def self.calculate(year:, month:, closing_day_of_month:, withdrawal_day_of_month:)
    year = year.to_i
    month = month.to_i
    closing_day_of_month = closing_day_of_month.to_i if closing_day_of_month
    withdrawal_day_of_month = withdrawal_day_of_month.to_i if withdrawal_day_of_month

    target_date = Date.new(year, month, 1)
    prev_prev_month = target_date.prev_month.prev_month
    prev_month = target_date.prev_month

    return [prev_month.beginning_of_month, prev_month.end_of_month] if closing_day_of_month == NO_CLOSING_DAY

    return [prev_prev_month.beginning_of_month, prev_month.end_of_month] if closing_day_of_month == END_OF_MONTH

    if closing_day_of_month < withdrawal_day_of_month
      begin_date = Date.new(year, month - 1, closing_day_of_month + 1)
      end_date = Date.new(year, month, closing_day_of_month)
    else
      begin_date = Date.new(year, month - 2, closing_day_of_month + 1)
      end_date = Date.new(year, month - 1, closing_day_of_month)
    end

    [begin_date, end_date]
  rescue Date::Error
    target_date = Date.new(year, month, 1)
    [target_date.beginning_of_month, target_date.end_of_month]
  end
end
