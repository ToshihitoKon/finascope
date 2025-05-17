# frozen_string_literal: true

module Constants
  RECORD_STATES = [
    { id: 0, label: "予定" },
    { id: 1, label: "支払済" },
    { id: 2, label: "検討中" },
    { id: 3, label: "やめた" }
  ].freeze
  def self.record_state(id)
    RECORD_STATES.find { it[:id] == id }
  end

  RECORD_TYPES = [
    { id: 0, label: "支出" },
    { id: 1, label: "収入" },
    { id: 2, label: "何？" }
  ].freeze
  def self.record_type(id)
    RECORD_TYPES.find { it[:id] == id }
  end

  INVOICE_RECORD_STATES = [
    { id: 0, label: "未確定" },
    { id: 1, label: "確定" },
    { id: 2, label: "処理済み" }
  ].freeze
  def self.invoice_record_state(id)
    INVOICE_RECORD_STATES.find { it[:id] == id }
  end

  HASH = {
    user_infromation_salt: "userinfo",
    user_salt: "user",
    algorithm: "aes-256-cbc",
    fixed_salt: "fixedsalt123456",
    fixed_iv: "fixediv123456789"
  }.freeze

  EXAMPLE_USER_UID = "example_user_uid"

  TODO_ID = {
    category: "TODO_CATEGORY_ID",
    payment_method: "TODO_PAYMENT_METHOD_ID"
  }.freeze
end
