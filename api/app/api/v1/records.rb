require "grape"
require "nanoid"
require "id"

module API
  module V1
    class Records < Grape::API
      resource :records do
        get do
          {
            records: [
              {
                name: "DIALOGUE+ カクノゴトキロックンロールチケ",
                id: ID.generate,
                typeLabel: "支出",
                stateLabel: "支払済",
                description: "全通",
                amount: 66_800,
                categoryLabel: "DIALOGUE+",
                date: "2025-02-20T00:00:00Z"
              },
              {
                name: "DIALOGUE+3 きゃにめ版",
                id: ID.generate,
                typeLabel: "支出",
                stateLabel: "支払済",
                description: "81直筆サインあたった神回",
                amount: 8800,
                categoryLabel: "DIALOGUE+",
                date: "2025-02-20T00:00:00Z"
              }
            ]
          }
        end
      end
    end
  end
end
