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
          categories = Service::Categories.all
          present categories, with: API::Entities::Categories::Category, root: :categories
        end
      end
    end
  end
end
