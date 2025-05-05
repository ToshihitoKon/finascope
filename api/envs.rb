# frozen_string_literal: true

module Envs
  DB_PATH = File.expand_path(ENV["FS_SQLITE_FILE"], __dir__)
end
