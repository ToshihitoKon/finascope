require "constants"
require "db/repositories"
require "lib/id"

module Service
  module PaymentMethods
    def self.all
      DB::Repository::PaymentMethod.all
    end

    def self.create(params)
      dto = DB::Model::PaymentMethod.dto.new(
        id: ID.generate,
        label: params[:label]
      )
      raise StandardError unless dto.valid?

      DB::Repository::PaymentMethod.create(dto)
    end
  end
end
