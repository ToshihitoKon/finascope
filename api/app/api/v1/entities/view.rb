require "grape-entity"

module API
  module Entities
    module View
      class CategoryAggregation < Grape::Entity
        expose :category_id
        expose :category
        expose :total_amount
        expose :record_count
      end
    end
  end
end