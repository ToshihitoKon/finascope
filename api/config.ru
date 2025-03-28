$LOAD_PATH.unshift(File.expand_path("./lib", __dir__))

require "./app/api/root"

run API::Root
