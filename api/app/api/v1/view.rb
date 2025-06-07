require "grape"
require "grape-entity"
require "date"

require "services/view"
require_relative "entities/view"
require_relative "entities/common"

module API
  module V1
    class View < Grape::API
      format :json

      resource :view do
        namespace :categories do
          get :aggregation do
            begin_date = Date.parse(params[:begin_date])&.beginning_of_day if params[:begin_date]
            end_date = Date.parse(params[:end_date])&.end_of_day if params[:end_date]

            uid = request_userdata[:uid]
            view_service = Service::View.new(uid:)
            aggregations = view_service.category_aggregation(begin_date:, end_date:)
            present aggregations, with: API::Entities::View::CategoryAggregation, root: :aggregations
          end
        end
      end
    end
  end
end