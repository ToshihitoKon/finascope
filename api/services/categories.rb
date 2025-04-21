require "constants"
require "db/repositories"
require "lib/id"

module Service
  module Categories
    def self.all
      DB::Repository::Category.all.map
    end
  end
end
