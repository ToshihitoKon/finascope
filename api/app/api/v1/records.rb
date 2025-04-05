require "grape"
require "id"
require "models"

module API
  module V1
    class Records < Grape::API
      RecordRequest = Struct.new(
        "RecordsRequest",
        :id, :type_id, :title, :amount, :category_id, :payment_method_id, :date, :description,
        keyword_init: true
      )

      RecordResponse = Struct.new(
        "RecordsResponse",
        :id, :type_label, :title, :amount, :category_label, :payment_method_label, :date, :description,
        keyword_init: true
      ) do
        def self.from_dto(record)
          category = DB::Model::Category.find_by_id(record.category_id)
          payment_method = DB::Model::PaymentMethod.find_by_id(record.payment_method_id)
          new(
            id: record.id,
            type_label: "TODO",
            title: record.title,
            amount: record.amount,
            category_label: category.label,
            payment_method_label: payment_method.label,
            date: record.date,
            description: record.description
          )
        end
      end
      RecordsResponse = Array[RecordResponse]

      resource :records do
        get do
          page = params[:page] ||= 1
          DB::Model::FinanceRecord.get_page(page: page, sort: { date: :asc }).map do |record|
            RecordResponse.from_dto(record)
          end
        end
      end
    end
  end
end
