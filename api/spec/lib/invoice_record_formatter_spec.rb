# frozen_string_literal: true

require "spec_helper"
require "constants"
require "lib/invoice_record_formatter"
require "lib/user_hash"

RSpec.describe InvoiceRecordFormatter do
  let(:uhash) do
    instance_double(UserHash).tap do |double|
      allow(double).to receive(:decrypt) { |value| "decrypted:#{value}" }
    end
  end
  let(:formatter) { described_class.new(uhash:) }
  let(:payment_method) do
    {
      id: "pm_1",
      encrypted_label: "enc_pm",
      withdrawal_day_of_month: 27
    }
  end

  describe "#format_monthly" do
    context "when an invoice exists" do
      it "uses invoice values and decrypts the payment method label" do
        invoice = {
          id: "inv_1",
          amount: 1500,
          withdrawal_date: Date.new(2026, 5, 27),
          state_id: 1
        }

        result = formatter.format_monthly(
          invoice:,
          payment_method:,
          calced_withdrawal_date: Date.new(2026, 5, 27)
        )

        expect(result[:id]).to eq("inv_1")
        expect(result[:amount]).to eq(1500)
        expect(result[:withdrawal_date]).to eq(Date.new(2026, 5, 27))
        expect(result[:state]).to eq(Constants.invoice_record_state(1)[:label])
        expect(result[:state_id]).to eq(1)
        expect(result[:payment_method]).to eq("decrypted:enc_pm")
        expect(result[:payment_method_id]).to eq("pm_1")
      end
    end

    context "when no invoice exists" do
      it "returns defaults and the calculated withdrawal date" do
        result = formatter.format_monthly(
          invoice: nil,
          payment_method:,
          calced_withdrawal_date: Date.new(2026, 5, 27)
        )

        expect(result[:id]).to eq("")
        expect(result[:amount]).to eq(0)
        expect(result[:withdrawal_date]).to eq(Date.new(2026, 5, 27))
        expect(result[:state]).to eq("")
        expect(result[:state_id]).to eq(0)
        expect(result[:payment_method]).to eq("decrypted:enc_pm")
        expect(result[:payment_method_id]).to eq("pm_1")
      end
    end
  end
end
