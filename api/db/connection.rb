require "active_record"
require_relative "../envs"

module DB
  class Connection
    def self.establish
      ActiveRecord::Base.establish_connection(
        adapter: "mysql2",
        host: ENV['MYSQL_HOST'],
        port: ENV['MYSQL_PORT'] || 3306,
        username: ENV['MYSQL_USER'],
        password: ENV['MYSQL_PASSWORD'],
        database: ENV['MYSQL_DATABASE']
      )
    end
  end
end
