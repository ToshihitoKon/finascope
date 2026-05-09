# frozen_string_literal: true

require "spec_helper"
require "lib/closing_period"

RSpec.describe ClosingPeriod do
  describe ".calculate" do
    context "when closing_day_of_month is 0 (no closing day)" do
      it "returns the previous month's full range" do
        begin_date, end_date = described_class.calculate(
          year: 2026, month: 5,
          closing_day_of_month: 0, withdrawal_day_of_month: 27
        )
        expect(begin_date).to eq(Date.new(2026, 4, 1))
        expect(end_date).to eq(Date.new(2026, 4, 30))
      end
    end

    context "when closing_day_of_month is -1 (end of month)" do
      it "returns from the first day of two months ago to the last day of the previous month" do
        begin_date, end_date = described_class.calculate(
          year: 2026, month: 5,
          closing_day_of_month: -1, withdrawal_day_of_month: 27
        )
        expect(begin_date).to eq(Date.new(2026, 3, 1))
        expect(end_date).to eq(Date.new(2026, 4, 30))
      end
    end

    context "when closing_day_of_month is less than withdrawal_day_of_month" do
      it "returns the period from the previous month's day after closing to the target month's closing day" do
        begin_date, end_date = described_class.calculate(
          year: 2026, month: 5,
          closing_day_of_month: 15, withdrawal_day_of_month: 27
        )
        expect(begin_date).to eq(Date.new(2026, 4, 16))
        expect(end_date).to eq(Date.new(2026, 5, 15))
      end
    end

    context "when closing_day_of_month is greater than or equal to withdrawal_day_of_month" do
      it "returns the period from two months before the day after closing to the previous month's closing day" do
        begin_date, end_date = described_class.calculate(
          year: 2026, month: 5,
          closing_day_of_month: 27, withdrawal_day_of_month: 10
        )
        expect(begin_date).to eq(Date.new(2026, 3, 28))
        expect(end_date).to eq(Date.new(2026, 4, 27))
      end
    end

    context "when an invalid date is constructed (Date::Error fallback)" do
      it "falls back to the target month's full range" do
        begin_date, end_date = described_class.calculate(
          year: 2026, month: 4,
          closing_day_of_month: 31, withdrawal_day_of_month: 10
        )
        expect(begin_date).to eq(Date.new(2026, 4, 1))
        expect(end_date).to eq(Date.new(2026, 4, 30))
      end
    end
  end
end
