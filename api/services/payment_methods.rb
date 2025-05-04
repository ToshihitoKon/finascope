require "constants"
require "db/repositories"
require "lib/id"
require "lib/exceptions"

module Service
  class PaymentMethods
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    def all
      DB::Repository::PaymentMethod
        .all(hashed_user_id: @hashed_uid)
        .map do |record|
        {
          **record,
          label: @uhash.decrypt(record[:encrypted_label])
        }
      end
    end

    def create(params)
      dto = DB::Model::PaymentMethod.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        encrypted_label: @uhash.encrypt(params[:label]),
        withdrawal_day_of_month: params[:withdrawal_day_of_month]
      )
      raise Exceptions::InvalidArgument unless dto.valid?

      DB::Repository::PaymentMethod.create(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::PaymentMethod.dto.new(
        encrypted_label: params[:label]&.present? ? @uhash.encrypt(params[:label]) : nil,
        withdrawal_day_of_month: params[:withdrawal_day_of_month]&.present? ? params[:withdrawal_day_of_month] : nil
      ).to_h.compact
      raise Exceptions::InvalidArgument.exception("no params to update") if params_dto.empty?

      DB::Repository::PaymentMethod.update(id:, params: params_dto)
    end
  end
end
