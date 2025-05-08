module Exceptions
  InternalServerError = StandardError.exception("Internal Server Error")
  InvalidArgument = StandardError.exception("Invalid Argument")
  NotFound = StandardError.exception("Not Found")
  Unauthorized = StandardError.exception("Unauthorized")
end
