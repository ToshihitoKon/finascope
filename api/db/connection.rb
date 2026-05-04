# frozen_string_literal: true

require "active_record"
require_relative "../envs"

module DB
  class Connection
    def self.establish
      ActiveRecord::Base.establish_connection(
        adapter: "mysql2",
        host: Envs::DB_HOST,
        database: Envs::DB_NAME,
        username: Envs::DB_USER,
        password: Envs::DB_PASSWORD,
        port: Envs::DB_PORT || 3306
      )
    end
  end
end
