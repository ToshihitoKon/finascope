# frozen_string_literal: true

require "active_support/cache"
require "constants"
require "db/repositories"
require "lib/exceptions"
require "lib/id"
require "lib/field_formatter"
require "services/base"

module Service
  class RecurringRecords < Base
    CACHE = ActiveSupport::Cache::MemoryStore.new

    def initialize(uid:)
      super
      @field = FieldFormatter.new(uhash: @uhash)
    end

    def get_all
      records = DB::Repository::RecurringRecord.all(hashed_user_id: @hashed_uid)
      records.map { |r| format_with_generated_count(r) }
    end

    def create(params)
      attrs = {
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        record_type_id: params[:record_type_id],
        state_id: params[:state_id],
        encrypted_title: @uhash.encrypt(params[:title]),
        amount: params[:amount],
        category_id: params[:category_id],
        payment_method_id: params[:payment_method_id],
        start_date: params[:start_date]
      }
      attrs[:encrypted_description] = @uhash.encrypt(params[:description]) if params[:description].present?
      attrs[:total_count] = params[:total_count] if params[:total_count]
      dto = DB::Model::RecurringRecord.dto.new(**attrs)
      result = persist(dto)
      invalidate_all_done_cache
      result
    end

    def update(id:, params:)
      params_dto = DB::Model::RecurringRecord.dto.new(
        record_type_id: params[:record_type_id],
        state_id: params[:state_id],
        encrypted_title: params[:title]&.present? ? @uhash.encrypt(params[:title]) : nil,
        amount: params[:amount],
        category_id: params[:category_id],
        payment_method_id: params[:payment_method_id],
        encrypted_description: params[:description]&.present? ? @uhash.encrypt(params[:description]) : nil,
        start_date: params[:start_date],
        total_count: params[:total_count]
      ).to_h.compact
      raise Exceptions::InvalidArgument, "no params to update" if params_dto.empty?

      DB::Repository::RecurringRecord.update(id:, params: params_dto)
    end

    def delete(id:)
      destroy(id:)
    end

    def generate(id:, year:, month:)
      recurring = DB::Repository::RecurringRecord.find(id:, hashed_user_id: @hashed_uid)

      if recurring[:total_count]
        generated = DB::Repository::RecurringRecord.generated_count(recurring_group_id: id)
        raise Exceptions::Conflict, "total_count reached for recurring record #{id}" if generated >= recurring[:total_count]
      end

      raise Exceptions::Conflict, "finance record already exists for #{id} #{year}/#{month}" if
        DB::Repository::FinanceRecord.exists_in_month?(recurring_group_id: id, year:, month:)

      build_and_create_finance_record(recurring:, id:, year:, month:)
    end

    def auto_generate_current_month
      year = Date.today.year
      month = Date.today.month
      return if CACHE.read(all_done_cache_key(year, month))

      records = DB::Repository::RecurringRecord.all(hashed_user_id: @hashed_uid)
      records.each do |recurring|
        id = recurring[:id]
        next if DB::Repository::FinanceRecord.exists_in_month?(recurring_group_id: id, year:, month:)
        next if recurring[:total_count] &&
                DB::Repository::RecurringRecord.generated_count(recurring_group_id: id) >= recurring[:total_count]

        build_and_create_finance_record(recurring:, id:, year:, month:)
      rescue StandardError
        next
      end
      CACHE.write(all_done_cache_key(year, month), true, expires_in: 1.hour)
    end

    private

    def repository = DB::Repository::RecurringRecord

    def all_done_cache_key(year, month)
      "#{@hashed_uid}-#{year}-#{month}-all_done"
    end

    def invalidate_all_done_cache
      year = Date.today.year
      month = Date.today.month
      CACHE.delete(all_done_cache_key(year, month))
    end

    def build_and_create_finance_record(recurring:, id:, year:, month:)
      date = Date.new(year, month, 1)
      attrs = {
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        record_type_id: recurring[:record_type_id],
        state_id: recurring[:state_id],
        encrypted_title: recurring[:encrypted_title],
        amount: recurring[:amount],
        category_id: recurring[:category_id],
        payment_method_id: recurring[:payment_method_id],
        date:,
        recurring_group_id: id
      }
      attrs[:encrypted_description] = recurring[:encrypted_description] if recurring[:encrypted_description]
      dto = DB::Model::FinanceRecord.dto.new(**attrs)
      dto.validate!
      DB::Repository::FinanceRecord.create(dto)
    end

    def format_with_generated_count(record)
      generated_count = DB::Repository::RecurringRecord.generated_count(recurring_group_id: record[:id])
      {
        **record,
        title: @field.value(record[:encrypted_title], default: ""),
        description: @field.value(record[:encrypted_description], default: ""),
        record_type: @field.constant_label(Constants.method(:record_type), record[:record_type_id]),
        state: @field.constant_label(Constants.method(:record_state), record[:state_id]),
        category: @field.value(record[:encrypted_category], default: FieldFormatter::TODO_LABEL),
        payment_method: @field.value(record[:encrypted_payment_method], default: FieldFormatter::TODO_LABEL),
        generated_count:
      }
    end
  end
end
