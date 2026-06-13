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

  describe "http_status mapping" do
    it "maps InternalServerError to 500" do
      expect(Exceptions::InternalServerError.http_status).to eq(500)
    end

    it "maps InvalidArgument to 422" do
      expect(Exceptions::InvalidArgument.http_status).to eq(422)
    end

    it "maps NotFound to 404" do
      expect(Exceptions::NotFound.http_status).to eq(404)
    end

    it "maps Unauthorized to 401" do
      expect(Exceptions::Unauthorized.http_status).to eq(401)
    end

    it "exposes http_status on instances" do
      expect(Exceptions::NotFound.new("x").http_status).to eq(404)
    end

    it "all exceptions inherit from Exceptions::Base" do
      [Exceptions::InternalServerError, Exceptions::InvalidArgument,
       Exceptions::NotFound, Exceptions::Unauthorized].each do |klass|
        expect(klass.ancestors).to include(Exceptions::Base)
      end
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
