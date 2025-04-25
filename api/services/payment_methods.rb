require "constants"
require "db/repositories"
require "lib/id"

module Service
  module PaymentMethods
    def self.all
      DB::Repository::PaymentMethod.all
    end
  end
end
