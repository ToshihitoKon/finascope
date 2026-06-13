# frozen_string_literal: true

require_relative "mixins"

module DB
  module Repository
    class Category
      extend Creatable
      extend Updatable

      def self.model
        @model ||= DB::Model::Category
      end
      private_class_method :model

      def self.all(hashed_user_id:)
        model.where(deleted_at: nil, hashed_user_id:).map do |record|
          model.to_dto(record).to_h
        end
      end
    end
  end
end
