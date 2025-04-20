require "grape"
require "date"

require "lib/id"
require "db/models"
require "services/records"

module API
  module V1
    class Records < Grape::API
      resource :records do
        get do
          page = params[:page] ||= 1
          records = Service::FinanceRecords.get_records(page: page).map do |record|
            {
              id: record[:id],
              type: record[:record_type],
              title: record[:title],
              amount: record[:amount],
              state_id: record[:state_id],
              category: record[:category],
              payment_method: record[:payment_method],
              date: record[:date],
              description: record[:description]
            }
          end
          { records: records }
        end
        post do
        end
      end
    end
  end
end
