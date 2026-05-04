# frozen_string_literal: true

RSpec.describe "Categories API" do
  before { stub_authenticated_user }

  describe "GET /api/v1/categories" do
    it "returns empty list initially" do
      get "/api/v1/categories", {}, auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:categories]).to eq([])
    end
  end

  describe "POST /api/v1/categories" do
    it "creates a category and returns it in the list" do
      post "/api/v1/categories", { label: "Food" }, auth_header
      expect(last_response.status).to eq(201)
      created_id = json_body[:id]
      expect(created_id).to be_a(String)

      get "/api/v1/categories", {}, auth_header
      labels = json_body[:categories].map { |c| c[:label] }
      expect(labels).to include("Food")
    end
  end

  describe "PUT /api/v1/categories/:id" do
    it "updates the label of an existing category" do
      post "/api/v1/categories", { label: "Old" }, auth_header
      id = json_body[:id]

      put "/api/v1/categories/#{id}", { id: id, label: "New" }, auth_header
      expect(last_response.status).to eq(200)

      get "/api/v1/categories", {}, auth_header
      labels = json_body[:categories].map { |c| c[:label] }
      expect(labels).to include("New")
      expect(labels).not_to include("Old")
    end
  end
end
