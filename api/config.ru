$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("./db", __dir__))

require "./app/api/root"
require "connection"

DB::Connection.establish

run API::Root
