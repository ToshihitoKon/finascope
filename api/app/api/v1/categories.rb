# frozen_string_literal: true

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
        desc "Get Categories",
             success: { model: API::Entities::Categories::Category, is_array: true, as: :categories }
        get do
          uid = request_userdata[:uid]
          categories_service = Service::Categories.new(uid:)
          categories = categories_service.all
          present categories, with: API::Entities::Categories::Category, root: :categories
        end

        desc "Create a Category",
             entity: API::Entities::Common::Response
        params do
          requires :label, type: String, desc: "(String) Category label"
        end
        post do
          uid = request_userdata[:uid]
          categories_service = Service::Categories.new(uid:)
          category = categories_service.create(label: params[:label])
          present_mutation_response(category)
        end

        desc "Update a Category",
             entity: API::Entities::Common::Response
        params do
          requires :id, type: String, desc: "(String) Category ID"
          requires :label, type: String, desc: "(String) Category label"
        end
        put ":id" do
          uid = request_userdata[:uid]
          categories_service = Service::Categories.new(uid:)
          category = categories_service.update(
            id: params[:id],
            params: {
              label: params[:label]
            }
          )
          present_mutation_response(category)
        end
      end
    end
  end
end
