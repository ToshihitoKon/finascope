# frozen_string_literal: true

RSpec.describe "InvoiceRecords API" do
  before { stub_authenticated_user }

  let(:invoice_record_params) do
    {
      amount: 5000,
      state_id: 0,
      withdrawal_date: "2026-05-27",
      payment_method_id: "TODO_PAYMENT_METHOD_ID"
    }
  end

  describe "POST /api/v1/invoice_records" do
    it "creates an invoice record and returns success" do
      post "/api/v1/invoice_records", invoice_record_params, auth_header
      expect(last_response.status).to eq(201)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to be_a(String)
    end
  end

  describe "PUT /api/v1/invoice_records/:id" do
    it "updates an existing invoice record and returns success" do
      post "/api/v1/invoice_records", invoice_record_params, auth_header
      id = json_body[:id]

      put "/api/v1/invoice_records/#{id}",
          { id: id, amount: 8000, state_id: 1, withdrawal_date: "2026-05-27" },
          auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to eq(id)
    end
  end
end
