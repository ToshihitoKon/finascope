require "constants"
require "db/repositories"
require "lib/id"

module Service
  class Categories
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    def all
      DB::Repository::Category
        .all(hashed_user_id: @hashed_uid)
        .map do |record|
        {
          **record,
          label: @uhash.decrypt(record[:encrypted_label])
        }
      end
    end

    def create(params)
      dto = DB::Model::Category.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        encrypted_label: @uhash.encrypt(params[:label])
      )
      raise StandardError unless dto.valid?

      DB::Repository::Category.create(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::Category.dto.new(
        encrypted_label: params[:label]&.present? ? @uhash.encrypt(params[:label]) : nil
      ).to_h.compact
      raise Exceptions::InvalidArgument.exception("no params to update") if params_dto.empty?

      DB::Repository::Category.update(id:, params: params_dto)
    end
  end
end
