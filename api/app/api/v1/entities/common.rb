# frozen_string_literal: true

module API
  module Entities
    class CommonResponse < Grape::Entity
      expose :status
      expose :id
    end
  end
end
