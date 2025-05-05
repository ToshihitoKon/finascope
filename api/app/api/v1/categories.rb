require "grape"
require "lib/id"
require "db/models"
require "services/categories"

require_relative "entities/categories"
require_relative "entities/common"

module API
  module V1
    class Categories < Grape::API
      resource :categories do
        get do
          uid = request_userdata[:uid]
          categories_service = Service::Categories.new(uid:)
          categories = categories_service.all
          present categories, with: API::Entities::Categories::Category, root: :categories
        end

        post do
          params do
            requires :label, type: String, desc: "Category label"
          end

          uid = request_userdata[:uid]
          categories_service = Service::Categories.new(uid:)
          category = categories_service.create(label: params[:label])

          if category
            status = "success"
          else
            status = "failed"
            status 422
          end
          resp = { status:, id: category&.id }
          present resp, with: API::Entities::CommonResponse
        end

        put ":id" do
          params do
            requires :id, type: String, desc: "PaymentMethod ID"
            requires :label, type: String, desc: "PaymentMethod label"
          end

          uid = request_userdata[:uid]
          categories_service = Service::Categories.new(uid:)
          category = categories_service.update(
            id: params[:id],
            params: {
              label: params[:label]
            }
          )

          if category.present?
            status = "success"
          else
            status = "failed"
            status 422
          end
          resp = { status:, id: category&.id }
          present resp, with: API::Entities::CommonResponse
        end
      end
    end
  end
end
