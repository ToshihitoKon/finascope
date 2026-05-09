# frozen_string_literal: true

module API
  module Entities
    module Common
      class Response < Grape::Entity
        expose :status
        expose :id
      end
    end
  end
end
