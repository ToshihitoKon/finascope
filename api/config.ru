$LOAD_PATH.unshift(File.expand_path("./", __dir__))

require "app/api/root"
require "db/connection"

DB::Connection.establish

run API::Root
