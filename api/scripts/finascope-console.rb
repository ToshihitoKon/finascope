#!/usr/bin/env ruby

require "irb"
require "irb/completion"

$LOAD_PATH.unshift(File.expand_path("../", __dir__))

require "app/api/root"
require "db/connection"
# require "db/utils"
# require "db/basewrapper"
# require "db/models"
# require "db/repositories"
# require "services/records"

DB::Connection.establish

puts "=== Start Finascope Console ==="

IRB.start
