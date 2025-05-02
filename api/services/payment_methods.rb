require "constants"
require "db/repositories"
require "lib/id"

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
      raise StandardError unless dto.valid?

      DB::Repository::PaymentMethod.create(dto)
    end
  end
end
