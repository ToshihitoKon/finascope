# frozen_string_literal: true

require "spec_helper"
require "constants"
require "lib/record_formatter"
require "lib/user_hash"

RSpec.describe RecordFormatter do
  let(:uhash) do
    instance_double(UserHash).tap do |double|
      allow(double).to receive(:decrypt) { |value| "decrypted:#{value}" }
    end
  end
  let(:formatter) { described_class.new(uhash:) }

  describe "#format" do
    context "with a fully populated record" do
      it "decrypts encrypted fields and resolves labels" do
        record = {
          id: "rec_1",
          record_type_id: 0,
          state_id: 1,
          encrypted_title: "enc_title",
          encrypted_description: "enc_desc",
          encrypted_category: "enc_cat",
          encrypted_payment_method: "enc_pm",
          amount: 1000
        }

        result = formatter.format(record)

        expect(result[:title]).to eq("decrypted:enc_title")
        expect(result[:description]).to eq("decrypted:enc_desc")
        expect(result[:category]).to eq("decrypted:enc_cat")
        expect(result[:payment_method]).to eq("decrypted:enc_pm")
        expect(result[:record_type]).to eq(Constants.record_type(0)[:label])
        expect(result[:state]).to eq(Constants.record_state(1)[:label])
        expect(result[:amount]).to eq(1000)
      end
    end

    context "when encrypted_category and encrypted_payment_method are nil" do
      it "treats them as TODO" do
        record = {
          id: "rec_2",
          record_type_id: 1,
          state_id: 0,
          encrypted_title: nil,
          encrypted_description: nil,
          encrypted_category: nil,
          encrypted_payment_method: nil,
          amount: 500
        }

        result = formatter.format(record)

        expect(result[:category]).to eq("TODO")
        expect(result[:payment_method]).to eq("TODO")
        expect(result[:title]).to eq("")
        expect(result[:description]).to eq("")
        expect(result[:record_type]).to eq(Constants.record_type(1)[:label])
        expect(result[:state]).to eq(Constants.record_state(0)[:label])
      end
    end
  end
end
