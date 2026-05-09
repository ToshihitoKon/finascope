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
  let(:formatter) { described_class.new(uhash:) }

  describe "#value" do
    it "returns the decrypted value when encrypted is present" do
      expect(formatter.value("enc_value")).to eq("decrypted:enc_value")
    end

    it "returns nil by default when encrypted is nil" do
      expect(formatter.value(nil)).to be_nil
    end

    it "returns the supplied default when encrypted is nil" do
      expect(formatter.value(nil, default: FieldFormatter::TODO_LABEL)).to eq("TODO")
      expect(formatter.value(nil, default: "")).to eq("")
    end
  end

  describe "#constant_label" do
    let(:lookup) do
      ->(id) { id == 1 ? { id: 1, label: "income" } : nil }
    end

    it "returns the :label of the looked-up entry" do
      expect(formatter.constant_label(lookup, 1)).to eq("income")
    end

    it "returns nil when the lookup returns nil" do
      expect(formatter.constant_label(lookup, 999)).to be_nil
    end
  end
end
