require "grape"
require "lib/id"
require "db/models"

module API
  module V1
    class Categories < Grape::API
      resource :categories do
        get do
          DB::Model::Category.all
        end
      end
    end
  end
end
