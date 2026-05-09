# frozen_string_literal: true

module Exceptions
  class InternalServerError < StandardError; end
  class InvalidArgument < StandardError; end
  class NotFound < StandardError; end
  class Unauthorized < StandardError; end
end
