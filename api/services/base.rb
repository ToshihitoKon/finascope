# frozen_string_literal: true

require "lib/user_hash"

module Service
  # Base class for service objects. Sets up the per-user encryption context
  # (@uhash / @hashed_uid) shared by every service, and provides the common
  # create/delete flow on top of each service's repository.
  class Base
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
    end

    private

    # The DB::Repository class this service persists through. Subclasses override.
    def repository
      raise NotImplementedError, "#{self.class} must implement #repository"
    end

    # Validate a freshly built DTO and create the record.
    def persist(dto)
      dto.validate!
      repository.create(dto)
    end

    # Soft-delete by id through the repository.
    def destroy(id:)
      repository.delete(id:)
    end
  end
end
