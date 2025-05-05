require "active_record"
require_relative "../envs"

module DB
  class Connection
    def self.establish
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: Envs::DB_PATH
      )
    end
  end
end
