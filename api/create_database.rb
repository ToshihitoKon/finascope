require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: File.expand_path("./db.dev.sqlite3", __dir__)
)

require_relative "./db/schema"
