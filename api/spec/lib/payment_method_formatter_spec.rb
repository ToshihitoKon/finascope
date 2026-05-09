# frozen_string_literal: true

require "spec_helper"
require "lib/payment_method_formatter"
require "lib/user_hash"

RSpec.describe PaymentMethodFormatter do
  let(:uhash) do
    instance_double(UserHash).tap do |double|
      allow(double).to receive(:decrypt) { |value| "decrypted:#{value}" }
    end
  end
  let(:formatter) { described_class.new(uhash:) }

  describe "#format" do
    it "decrypts encrypted_label into label and preserves other fields" do
      record = {
        id: "pm_1",
        encrypted_label: "enc_label",
        withdrawal_day_of_month: 27,
        closing_day_of_month: 15
      }

      result = formatter.format(record)

      expect(result[:id]).to eq("pm_1")
      expect(result[:label]).to eq("decrypted:enc_label")
      expect(result[:withdrawal_day_of_month]).to eq(27)
      expect(result[:closing_day_of_month]).to eq(15)
    end

    it "returns TODO when encrypted_label is nil" do
      record = { id: "pm_2", encrypted_label: nil }

      result = formatter.format(record)

      expect(result[:label]).to eq("TODO")
    end
  end
end
