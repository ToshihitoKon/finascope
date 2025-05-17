module API
  module Entities
    module Categories
      class Category < Grape::Entity
        expose :id, documentation: { type: String, desc: "Category ID" }
        expose :label, documentation: { type: String, desc: "Category label" }
      end
    end
  end
end
