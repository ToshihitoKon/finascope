require "grape"
require "lib/firebase"
require_relative "./v1/root"

module API
  class Root < Grape::API
    format :json
    helpers do
      def authorization_header
        headers["Authorization"]
      end

      def request_bearer
        b = authorization_header&.gsub("Bearer ", "")
        return Constants::EXAMPLE_USER_UID if b.blank?

        b
      end

      def request_uid
        jwt = authorization_header&.gsub("Bearer ", "")
        return Constants::EXAMPLE_USER_UID if jwt.blank?

        payload = Firebase.decode_jwt(jwt)
        puts payload
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
