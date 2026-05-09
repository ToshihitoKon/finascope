# frozen_string_literal: true

require "spec_helper"
require "lib/field_formatter"
require "lib/user_hash"

RSpec.describe FieldFormatter do
  let(:uhash) do
    instance_double(UserHash).tap do |double|
      allow(double).to receive(:decrypt) { |value| "decrypted:#{value}" }
    end
  end

  describe ".label" do
    it "returns the decrypted value when encrypted is present" do
      expect(described_class.label("enc_value", uhash)).to eq("decrypted:enc_value")
    end

    it "returns TODO_LABEL when encrypted is nil" do
      expect(described_class.label(nil, uhash)).to eq(FieldFormatter::TODO_LABEL)
    end
  end

  describe ".text" do
    it "returns the decrypted value when encrypted is present" do
      expect(described_class.text("enc_text", uhash)).to eq("decrypted:enc_text")
    end

    it "returns nil when encrypted is nil" do
      expect(described_class.text(nil, uhash)).to be_nil
    end
  end

  describe ".constant_label" do
    it "returns the :label field of the lookup result" do
      expect(described_class.constant_label({ id: 1, label: "income" })).to eq("income")
    end

    it "returns nil when the lookup result is nil" do
      expect(described_class.constant_label(nil)).to be_nil
    end
  end
end
