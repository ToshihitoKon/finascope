# frozen_string_literal: true

require "spec_helper"
require "lib/category_formatter"
require "lib/user_hash"

RSpec.describe CategoryFormatter do
  let(:uhash) do
    instance_double(UserHash).tap do |double|
      allow(double).to receive(:decrypt) { |value| "decrypted:#{value}" }
    end
  end
  let(:formatter) { described_class.new(uhash:) }

  describe "#format" do
    it "decrypts encrypted_label into label and preserves other fields" do
      record = { id: "cat_1", encrypted_label: "enc_label" }

      result = formatter.format(record)

      expect(result[:id]).to eq("cat_1")
      expect(result[:label]).to eq("decrypted:enc_label")
      expect(result[:encrypted_label]).to eq("enc_label")
    end

    it "returns TODO when encrypted_label is nil" do
      record = { id: "cat_2", encrypted_label: nil }

      result = formatter.format(record)

      expect(result[:label]).to eq("TODO")
    end
  end
end
