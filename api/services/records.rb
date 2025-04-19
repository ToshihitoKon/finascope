require "db/repositories"

module Service
  module FinanceRecords
    def self.get_records(page: 1)
      records = DB::Repository::FinanceRecord.get_page(page: page, sort: { date: :asc })
      # category_ids = records.map(&:category_id).uniq
      # categories = DB::Model::Category.where(id: category_ids)

      # payment_method_ids = records.map(&:payment_method_id).uniq
      # payment_methods = DB::Model::PaymentMethod.where(id: payment_method_ids)

      # type_ids = records.map(&:type_id).uniq
      # types = DB::Model::Types.where(id: type_ids)

      records.map do |record|
        # category = categories.find { it.id == record.category_id }
        # payment_method = payment_methods.find { it.id == record.payment_method_id }
        # type = types.find { |t| t.id == record.type_id }

        {
          id: record[:id],
          type: "TODO",
          title: record[:title],
          amount: record[:amount],
          category: "TODO", # category&.label,
          payment_method: "TODO", # payment_method&.label,
          state_id: record[:state],
          date: record[:date],
          description: record[:description]
        }
      end
    end
  end
end
