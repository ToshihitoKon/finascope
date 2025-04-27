require "constants"
require "db/repositories"
require "lib/id"

module Service
  module Categories
    def self.all
      DB::Repository::Category.all
    end

    def self.create(params)
      dto = DB::Model::Category.dto.new(
        id: ID.generate,
        label: params[:label]
      )
      raise StandardError unless dto.valid?

      DB::Repository::Category.create(dto)
    end
  end
end
