# frozen_string_literal: true

RSpec.describe "PaymentMethods API" do
  before { stub_authenticated_user }

  let(:payment_method_params) do
    {
      label: "Credit Card",
      withdrawal_day_of_month: 27,
      closing_day_of_month: 15
    }
  end

  describe "GET /api/v1/payment_methods" do
    it "returns empty list initially" do
      get "/api/v1/payment_methods", {}, auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:payment_methods]).to eq([])
    end
  end

  describe "POST /api/v1/payment_methods" do
    it "creates a payment method and returns success" do
      post "/api/v1/payment_methods", payment_method_params, auth_header
      expect(last_response.status).to eq(201)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to be_a(String)

      get "/api/v1/payment_methods", {}, auth_header
      labels = json_body[:payment_methods].map { |pm| pm[:label] }
      expect(labels).to include("Credit Card")
    end
  end

  describe "PUT /api/v1/payment_methods/:id" do
    it "updates the label of an existing payment method" do
      post "/api/v1/payment_methods", payment_method_params, auth_header
      id = json_body[:id]

      put "/api/v1/payment_methods/#{id}",
          { id: id, label: "Debit Card", withdrawal_day_of_month: 27 },
          auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:status]).to eq("success")

      get "/api/v1/payment_methods", {}, auth_header
      labels = json_body[:payment_methods].map { |pm| pm[:label] }
      expect(labels).to include("Debit Card")
      expect(labels).not_to include("Credit Card")
    end
  end
end
