require "grape-entity"

module API
  module Entities
    module View
      class CategoryRecord < Grape::Entity
        expose :id
        expose :amount
        expose :note
        expose :date
        expose :payment_method
      end

      class CategoryAggregation < Grape::Entity
        expose :category_id
        expose :category
        expose :total_amount
        expose :record_count
        expose :records, using: CategoryRecord
      end
    end
  end
end