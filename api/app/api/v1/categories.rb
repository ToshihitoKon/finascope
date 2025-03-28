require "grape"

module API
  module V1
    class Categories < Grape::API
      resource :categories do
        get do
          {
            categories: [
              { id: "01JNB8PFPXAC808XH263PS7TW9", label: "DIALOGUE+" },
              { id: "01JNB8PNR9RT2HF21PVRFSW5NV", label: "その他" }
            ]
          }
        end
      end
    end
  end
end
