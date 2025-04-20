#!/usr/bin/env ruby

require "irb"
require "irb/completion"

require_relative "../db/connection"
require_relative "../db/utils"
require_relative "../db/basewrapper"
require_relative "../db/models"
require_relative "../db/repositories"

DB::Connection.establish

puts "=== Start Finascope Console ==="

IRB.start
