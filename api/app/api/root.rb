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

      def request_userdata
        jwt = authorization_header&.gsub("Bearer ", "")
        return { uid: Constants::EXAMPLE_USER_UID } if jwt.blank?

        begin
          Firebase.decode_jwt(jwt)
        rescue JWT::DecodeError
          error!({ error: "failed to validate JWT", status: 401 }, 401)
        end
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
