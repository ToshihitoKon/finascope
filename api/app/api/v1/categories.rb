require "grape"
require "lib/id"
require "db/models"
require "services/categories"

module API
  module V1
    class Categories < Grape::API
      resource :categories do
        get do
          categories = Service::Categories.all.map do |category|
            {
              id: category[:id],
              label: category[:label]
            }
          end

          { categories: }
        end
      end
    end
  end
end
