module Constants
  RECORD_TYPES = [
    { id: 0, label: "予定" },
    { id: 1, label: "支払済" },
    { id: 2, label: "検討中" },
    { id: 3, label: "やめた" }
  ].freeze
  def self.record_types(id)
    RECORD_TYPES.find { it[:id] == id }
  end
end
