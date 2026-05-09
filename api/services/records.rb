# frozen_string_literal: true

require "constants"
require "db/repositories"
require "lib/id"
require "lib/finance_record_formatter"

module Service
  class FinanceRecords
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
      @formatter = FinanceRecordFormatter.new(uhash: @uhash)
    end

    def get_records(page: nil, sort: { date: :desc }, begin_date: nil, end_date: nil)
      opts = { hashed_user_id: @hashed_uid, sort:, page:, begin_date:, end_date: }.compact
      records = DB::Repository::FinanceRecord.get_page(**opts)
      records.map { @formatter.format(it) }
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
      raise Exceptions::InvalidArgument, "no params to update" if params_dto.empty?

      DB::Repository::FinanceRecord.update(id:, params: params_dto)
    end

    def delete(id:)
      DB::Repository::FinanceRecord.delete(id:)
    end
  end
end
