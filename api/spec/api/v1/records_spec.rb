# frozen_string_literal: true

RSpec.describe "Records API" do
  before { stub_authenticated_user }

  let(:record_params) do
    {
      title: "Test Record",
      type_id: 0,
      state_id: 0,
      description: "Test description",
      amount: 1000,
      category_id: "TODO_CATEGORY_ID",
      payment_method_id: "TODO_PAYMENT_METHOD_ID",
      date: "2026-05-01"
    }
  end

  describe "POST /api/v1/records" do
    it "creates a record successfully" do
      post "/api/v1/records", record_params, auth_header
      expect(last_response.status).to eq(201)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to be_a(String)
    end
  end

  describe "GET /api/v1/records" do
    it "returns created record in the list" do
      post "/api/v1/records", record_params, auth_header
      created_id = json_body[:id]

      get "/api/v1/records", {}, auth_header
      expect(last_response.status).to eq(200)
      ids = json_body[:records].map { |r| r[:id] }
      expect(ids).to include(created_id)
    end
  end
end
