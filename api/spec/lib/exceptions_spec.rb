# frozen_string_literal: true

require "spec_helper"
require "lib/exceptions"

RSpec.describe Exceptions do
  describe "class hierarchy" do
    it "InternalServerError inherits from StandardError" do
      expect(Exceptions::InternalServerError.ancestors).to include(StandardError)
    end

    it "InvalidArgument inherits from StandardError" do
      expect(Exceptions::InvalidArgument.ancestors).to include(StandardError)
    end

    it "NotFound inherits from StandardError" do
      expect(Exceptions::NotFound.ancestors).to include(StandardError)
    end

    it "Unauthorized inherits from StandardError" do
      expect(Exceptions::Unauthorized.ancestors).to include(StandardError)
    end
  end

  describe "raise behavior" do
    it "can be raised with a message" do
      expect { raise Exceptions::NotFound, "missing" }
        .to raise_error(Exceptions::NotFound, "missing")
    end

    it "can be raised without arguments" do
      expect { raise Exceptions::InvalidArgument }
        .to raise_error(Exceptions::InvalidArgument)
    end

    it "is not caught by rescue clause for a different class" do
      expect do
        raise Exceptions::InvalidArgument, "bad"
      rescue Exceptions::NotFound
        # not expected to be caught here
      end.to raise_error(Exceptions::InvalidArgument)
    end

    it "is caught by rescue clause for the same class" do
      caught = nil
      begin
        raise Exceptions::Unauthorized, "no token"
      rescue Exceptions::Unauthorized => e
        caught = e
      end
      expect(caught).to be_a(Exceptions::Unauthorized)
      expect(caught.message).to eq("no token")
    end
  end
end
