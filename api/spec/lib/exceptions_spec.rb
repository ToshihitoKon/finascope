# frozen_string_literal: true

require "spec_helper"
require "lib/exceptions"

RSpec.describe Exceptions do
  describe "クラス階層" do
    it "InternalServerError は StandardError を継承する" do
      expect(Exceptions::InternalServerError.ancestors).to include(StandardError)
    end

    it "InvalidArgument は StandardError を継承する" do
      expect(Exceptions::InvalidArgument.ancestors).to include(StandardError)
    end

    it "NotFound は StandardError を継承する" do
      expect(Exceptions::NotFound.ancestors).to include(StandardError)
    end

    it "Unauthorized は StandardError を継承する" do
      expect(Exceptions::Unauthorized.ancestors).to include(StandardError)
    end
  end

  describe "raise の挙動" do
    it "メッセージ付きで raise できる" do
      expect { raise Exceptions::NotFound, "missing" }
        .to raise_error(Exceptions::NotFound, "missing")
    end

    it "引数なしでも raise できる" do
      expect { raise Exceptions::InvalidArgument }
        .to raise_error(Exceptions::InvalidArgument)
    end

    it "型による rescue が機能する（別クラスでは捕捉されない）" do
      expect do
        raise Exceptions::InvalidArgument, "bad"
      rescue Exceptions::NotFound
        # 捕捉されない想定
      end.to raise_error(Exceptions::InvalidArgument)
    end

    it "型による rescue が機能する（同クラスで捕捉される）" do
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
