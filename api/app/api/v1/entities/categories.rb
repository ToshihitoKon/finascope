module API
  module Entities
    module Categories
      class Category < Grape::Entity
        expose :id, documentation: { type: Integer, desc: "Category ID" }
        expose :label, documentation: { type: String, desc: "Category label" }
      end

      class PutResponse < Grape::Entity
        expose :status
        expose :id
      end
    end
  end
end
