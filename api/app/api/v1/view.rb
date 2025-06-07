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
            params do
              optional :begin_date, type: String, desc: "Start date in YYYY-MM-DD format"
              optional :end_date, type: String, desc: "End date in YYYY-MM-DD format"
            end

            # 期間指定のバリデーション
            if (params[:begin_date].present? && params[:end_date].blank?) ||
               (params[:begin_date].blank? && params[:end_date].present?)
              error!("Both begin_date and end_date must be specified together", 400)
            end

            # 日付パース
            begin_date = nil
            end_date = nil

            if params[:begin_date].present? && params[:end_date].present?
              begin_date = Date.parse(params[:begin_date]).beginning_of_day
              end_date = Date.parse(params[:end_date]).end_of_day
            else
              # デフォルト: 今月の頭から最終日まで
              today = Date.today
              begin_date = today.beginning_of_month.beginning_of_day
              end_date = today.end_of_month.end_of_day
            end

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