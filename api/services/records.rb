# frozen_string_literal: true

require "constants"
require "db/repositories"
require "lib/exceptions"
require "lib/id"
require "lib/finance_record_formatter"
require "services/base"

module Service
  class FinanceRecords < Base
    def initialize(uid:)
      super
      @formatter = FinanceRecordFormatter.new(uhash: @uhash)
    end

    def get_records(page: nil, sort: { date: :desc }, begin_date: nil, end_date: nil, recurring: nil)
      opts = { hashed_user_id: @hashed_uid, sort:, page:, begin_date:, end_date:, recurring: }.compact
      records = DB::Repository::FinanceRecord.get_page(**opts)
      records.map { @formatter.format(it) }
    end

    def create(params)
      attrs = {
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
      }
      attrs[:recurring_group_id] = params[:recurring_group_id] if params[:recurring_group_id]
      dto = DB::Model::FinanceRecord.dto.new(**attrs)
      persist(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::FinanceRecord.dto.new(
        record_type_id: params[:record_type_id],
        encrypted_title: params[:title]&.present? ? @uhash.encrypt(params[:title]) : nil,
        amount: params[:amount],
        category_id: params[:category_id],
        payment_method_id: params[:payment_method_id],
        state_id: params[:state_id],
        date: params[:date],
        encrypted_description: params[:description]&.present? ? @uhash.encrypt(params[:description]) : nil,
        recurring_group_id: params[:recurring_group_id]
      ).to_h.compact
      raise Exceptions::InvalidArgument, "no params to update" if params_dto.empty?

      DB::Repository::FinanceRecord.update(id:, params: params_dto)
    end

    def delete(id:)
      destroy(id:)
    end

    private

    def repository = DB::Repository::FinanceRecord
  end
end
