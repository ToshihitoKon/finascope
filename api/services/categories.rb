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
      categories = DB::Repository::Category.all(@hashed_uid)
      categories.map do |record|
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
  end
end
