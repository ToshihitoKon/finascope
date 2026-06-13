# frozen_string_literal: true

require "constants"
require "db/repositories"
require "lib/closing_period"
require "lib/exceptions"
require "lib/finance_record_formatter"
require "lib/id"
require "lib/invoice_record_formatter"

module Service
  class InvoiceRecords
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
      @formatter = FinanceRecordFormatter.new(uhash: @uhash)
      @invoice_formatter = InvoiceRecordFormatter.new(uhash: @uhash)
    end

    def create(params)
      dto = DB::Model::InvoiceRecord.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        amount: params[:amount],
        state_id: params[:state_id],
        payment_method_id: params[:payment_method_id],
        withdrawal_date: params[:withdrawal_date]
      )
      raise Exceptions::InvalidArgument, "missing required fields: #{dto.invalid_members.join(', ')}" unless dto.valid?

      DB::Repository::InvoiceRecord.create(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::InvoiceRecord.dto.new(
        amount: params[:amount],
        state_id: params[:state_id],
        withdrawal_date: params[:withdrawal_date]
      ).to_h.compact
      raise Exceptions::InvalidArgument, "no params to update" if params_dto.empty?

      DB::Repository::InvoiceRecord.update(id:, params: params_dto)
    end

    def delete(id:)
      DB::Repository::InvoiceRecord.delete(id:)
    end

    def monthly_records(year: nil, month: nil)
      # TODO: return all payment methods
      year ||= Date.today.year
      month ||= Date.today.month

      invoices = DB::Repository::InvoiceRecord.monthly_records(
        hashed_user_id: @hashed_uid, year:, month:
      )

      payment_methods = DB::Repository::PaymentMethod
                        .all(hashed_user_id: @hashed_uid)
                        .filter { it[:withdrawal_day_of_month] != 0 } # 0 は引き落とし日とかない

      payment_methods.map do |payment_method|
        invoice = invoices.find { it[:payment_method_id] == payment_method[:id] }
        calced_withdrawal_date = calc_withdrawal_date(
          year,
          month,
          payment_method[:withdrawal_day_of_month]
        )

        @invoice_formatter.format_monthly(
          invoice:,
          payment_method:,
          calced_withdrawal_date:
        )
      end
    end

    def withdrawal_records_aggregation(year:, month:, payment_method_id:)
      payment_method = DB::Repository::PaymentMethod.get(id: payment_method_id)

      raise Exceptions::InvalidArgument, "payment method not found" unless payment_method

      begin_date, end_date = ClosingPeriod.calculate(
        year:,
        month:,
        closing_day_of_month: payment_method[:closing_day_of_month],
        withdrawal_day_of_month: payment_method[:withdrawal_day_of_month]
      )

      records = DB::Repository::FinanceRecord.get_withdrawal_records_for_invoice(
        hashed_user_id: @hashed_uid,
        year:,
        month:,
        payment_method_id:,
        begin_date:,
        end_date:
      )

      payment_method_name = @uhash.decrypt(payment_method[:encrypted_label])

      formatted_records = records.map { @formatter.format(it) }

      total_amount = records.sum { |record| record[:amount] || 0 }

      {
        payment_method_id:,
        payment_method: payment_method_name,
        total_amount:,
        begin_date: begin_date.to_s,
        end_date: end_date.to_s,
        records: formatted_records
      }
    end

    private

    def calc_withdrawal_date(year, month, day_of_month)
      begin
        withdrawal_date = case day_of_month == -1
                          when 0 then nil
                          when -1 then Date.new(year, month).end_of_month
                          else
                            Date.new(year, month, day_of_month)
                          end

        if withdrawal_date&.saturday?
          withdrawal_date += 2
        elsif withdrawal_date&.sunday?
          withdrawal_date += 1
        end
      rescue Date::Error # Invalid day of month (ex. 2023-02-30)
        Date.new(year, month).end_of_month # わからんけどとりあえず最終日を返しておく
      end
      withdrawal_date
    end
  end
end
