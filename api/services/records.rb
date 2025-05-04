require "constants"
require "db/repositories"
require "lib/id"

module Service
  class FinanceRecords
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    def get_records(page: nil, sort: { date: :desc }, begin_date: nil, end_date: nil)
      opts = { hashed_user_id: @hashed_uid, sort:, page:, begin_date:, end_date: }.compact
      records = DB::Repository::FinanceRecord.get_page(**opts)
      records.map do |record|
        {
          **record,
          title: @uhash.decrypt(record[:encrypted_title]),
          description: @uhash.decrypt(record[:encrypted_description]),
          category: @uhash.decrypt(record[:encrypted_category]),
          payment_method: @uhash.decrypt(record[:encrypted_payment_method]),
          record_type: Constants.record_type(record[:record_type_id])[:label],
          state: Constants.record_state(record[:state_id])[:label]
        }
      end
    end

    def create(params)
      dto = DB::Model::FinanceRecord.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        record_type_id: params[:record_type_id],
        encrypted_title: @uhash.encrypt(params[:title]),
        amount: params[:amount],
        category_id: params[:category_id],
        payment_method_id: params[:payment_method_id],
        state_id: params[:state_id],
        date: params[:date],
        encrypted_description: @uhash.encrypt(params[:description])
      )
      raise StandardError unless dto.valid? # TODO: ちゃんとした Exception を作る

      DB::Repository::FinanceRecord.create(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::FinanceRecord.dto.new(
        record_type_id: params[:record_type_id],
        encrypted_title: @uhash.encrypt(params[:title]),
        amount: params[:amount],
        category_id: params[:category_id],
        payment_method_id: params[:payment_method_id],
        state_id: params[:state_id],
        date: params[:date],
        encrypted_description: @uhash.encrypt(params[:description])
      ).to_h.compact
      raise Exceptions::InvalidArgument.exception("no params to update") if params_dto.empty?

      DB::Repository::FinanceRecord.update(id:, params: params_dto)
    end
  end
end
