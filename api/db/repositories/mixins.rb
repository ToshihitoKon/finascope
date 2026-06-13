# frozen_string_literal: true

require "lib/exceptions"

module DB
  module Repository
    # Shared mutation helpers extended onto repository classes.
    # Each module relies on the host class defining `self.model`.

    # Provides `create(dto)`.
    module Creatable
      def create(dto)
        model.create(**dto.to_h)
      end
    end

    # Provides `update(id:, params:)`.
    # Raises NotFound when the record is missing, InternalServerError on failure.
    module Updatable
      def update(id:, params:)
        record = model.where(id:).first
        raise Exceptions::NotFound, "record not found: #{id}" if record.nil?
        return record if record.update(**params)

        raise Exceptions::InternalServerError, "failed to record update #{id}"
      end
    end

    # Provides `delete(id:)` via soft delete. Raises NotFound when nothing matched.
    module SoftDeletable
      def delete(id:)
        return if model.soft_delete(where_clause: { id: }).positive?

        raise Exceptions::NotFound, "record not found: #{id}"
      end
    end
  end
end
