# frozen_string_literal: true

require "rack/test"

module ApiHelper
  include Rack::Test::Methods

  def app
    API::Root
  end

  def json_body
    JSON.parse(last_response.body, symbolize_names: true)
  end
end
