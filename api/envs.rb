# frozen_string_literal: true

module Envs
  DB_HOST = ENV.fetch("DB_HOST", "localhost")
  DB_NAME = ENV.fetch("DB_NAME", "app_database")
  DB_USER = ENV.fetch("DB_USER", "app_user")
  DB_PASSWORD = ENV.fetch("DB_PASSWORD", "password")
  DB_PORT = ENV.fetch("DB_PORT", "3306")
  USER_SALT = ENV.fetch("USER_SALT", "dev_user_salt_placeholder")
  FIXED_SALT = ENV.fetch("FIXED_SALT", "dev_fixed_salt_placeholder")
end
