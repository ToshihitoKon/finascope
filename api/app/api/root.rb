require "grape"
require_relative "./v1/root"

module API
  class Root < Grape::API
    format :json
    helpers do
      def authorization_header
        headers["Authorization"]
      end

      def request_bearer
        authorization_header&.gsub("Bearer ", "") || Constants::EXAMPLE_USER_UID
      end
    end

    prefix :api
    mount API::V1::Root

    resource :healthcheck do
      get do
        { status: "healthy" }
      end
    end
  end
end
