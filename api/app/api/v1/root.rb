require "grape"
require_relative "./records"
require_relative "./categories"

module API
  module V1
    class Root < Grape::API
      format :json
      version "v1"

      mount API::V1::Records
      mount API::V1::Categories

      resource :healthcheck do
        get do
          { status: "healthy" }
        end
      end
    end
  end
end
