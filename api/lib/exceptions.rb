module Exceptions
  InternalServerError = Exception.new("Internal Server Error")
  InvalidArgument = Exception.new("Invalid Argument")
  NotFound = Exception.new("Not Found")
end
