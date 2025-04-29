require "grape"
require "lib/id"
require "db/models"
require "services/categories"

require_relative "entities/categories"

module API
  module V1
    class Categories < Grape::API
      resource :categories do
        get do
          categories_service = Service::Categories.new(uid: request_bearer)
          categories = categories_service.all
          present categories, with: API::Entities::Categories::Category, root: :categories
        end

        put do
          params do
            requires :label, type: String, desc: "Category label"
          end

          categories_service = Service::Categories.new(uid: request_bearer)
          category = categories_service.create(label: params[:label])

          if category
            status = "success"
          else
            status = "failed"
            status 422
          end
          resp = { status:, id: category&.id }
          present resp, with: API::Entities::Categories::PutResponse
        end
      end
    end
  end
end
