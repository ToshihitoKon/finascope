# frozen_string_literal: true

require 'grape-entity'
require_relative 'records'

module API
  module Entities
    module View
      class CategoryAggregation < Grape::Entity
        expose :category_id
        expose :category
        expose :total_amount
        expose :record_count
        expose :records, using: API::Entities::Records::Record
      end
    end
  end
end
