require "constants"
require "db/repositories"
require "lib/id"

module Service
  class InvoiceRecords
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    def monthly_records(year: nil, month: nil)
      # TODO: return all payment methods
      year ||= Date.today.year
      month ||= Date.today.month

      records = DB::Repository::InvoiceRecord
                .monthly_records(hashed_user_id: @hashed_uid, year:, month:)
                .map do |record|
        {
          **record,
          state: Constants.invoice_record_state(record[:state_id])[:label]
        }
      end

      payment_methods = DB::Repository::PaymentMethod
                        .all(hashed_user_id: @hashed_uid)
                        .filter { it[:withdrawal_day_of_month] != 0 } # 0 は引き落とし日とかない

      payment_methods.map do |record|
        invoice = records.find { it[:payment_method_id] == record[:id] }
        calced_withdrawal_date = calc_withdrawal_date(
          year,
          month,
          record[:withdrawal_day_of_month]
        )
        {
          payment_method: {
            **record,
            payment_method: @uhash.decrypt(record[:encrypted_label])
          },
          invoice:,
          calced_withdrawal_date:
        }
      end
    end

    def create(params)
      dto = DB::Model::InvoiceRecord.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        amount: params[:amount],
        payment_method_id: params[:payment_method_id],
        withdrawal_date: params[:withdrawal_date]
      )
      raise StandardError unless dto.valid?

      DB::Repository::InvoiceRecord.create(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::InvoiceRecord.dto.new(
        state_id: params[:state_id],
        withdrawal_date: params[:withdrawal_date],
        amount: params[:amount]
      ).to_h.compact
      raise Exceptions::InvalidArgument.exception("no params to update") if params_dto.empty?

      DB::Repository::InvoiceRecord.update(id:, params: params_dto)
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
