# frozen_string_literal: true

require "constants"
require "db/repositories"
require "lib/category_formatter"
require "lib/exceptions"
require "lib/id"

module Service
  class Categories
    def initialize(uid:)
      @uhash = UserHash.new(uid)
      @hashed_uid = @uhash.user_hash
      @formatter = CategoryFormatter.new(uhash: @uhash)
    end

    def all
      DB::Repository::Category
        .all(hashed_user_id: @hashed_uid)
        .map { @formatter.format(it) }
    end

    def create(params)
      dto = DB::Model::Category.dto.new(
        id: ID.generate,
        hashed_user_id: @hashed_uid,
        encrypted_label: @uhash.encrypt(params[:label])
      )
      raise Exceptions::InvalidArgument, "missing required fields: #{dto.invalid_members.join(', ')}" unless dto.valid?

      DB::Repository::Category.create(dto)
    end

    def update(id:, params:)
      params_dto = DB::Model::Category.dto.new(
        encrypted_label: params[:label]&.present? ? @uhash.encrypt(params[:label]) : nil
      ).to_h.compact
      raise Exceptions::InvalidArgument, "no params to update" if params_dto.empty?

      DB::Repository::Category.update(id:, params: params_dto)
    end
  end
end
