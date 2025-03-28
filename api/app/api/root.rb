require "grape"
require_relative "./v1/root"

module API
  class Root < Grape::API
    format :json
    prefix :api

    mount API::V1::Root

    resource :healthcheck do
      get do
        { status: "healthy" }
      end
    end
  end
end
