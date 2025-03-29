require "active_record"

module DB
  class Connection
    def self.establish
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: File.expand_path("../data/db.dev.sqlite3", __dir__)
      )
    end
  end
end
