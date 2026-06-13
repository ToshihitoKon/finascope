# frozen_string_literal: true

module Exceptions
  # Base class carrying the HTTP status that the API layer maps the exception to.
  class Base < StandardError
    def self.http_status
      500
    end

    def http_status
      self.class.http_status
    end
  end

  class InternalServerError < Base
    def self.http_status
      500
    end
  end

  class InvalidArgument < Base
    def self.http_status
      422
    end
  end

  class NotFound < Base
    def self.http_status
      404
    end
  end

  class Unauthorized < Base
    def self.http_status
      401
    end
  end
end
