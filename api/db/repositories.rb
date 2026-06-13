# frozen_string_literal: true

# Aggregator: requiring "db/repositories" loads every repository.
# Individual repositories live under db/repositories/.
require "lib/user_hash"

require_relative "repositories/mixins"
require_relative "repositories/finance_records"
require_relative "repositories/categories"
require_relative "repositories/payment_methods"
require_relative "repositories/invoice_records"
