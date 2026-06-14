# frozen_string_literal: true

RSpec.describe "RecurringRecords API" do
  before { stub_authenticated_user }

  let(:today) { Date.today }

  let(:recurring_params) do
    {
      title: "Netflix",
      type_id: 0,
      state_id: 0,
      description: "monthly subscription",
      amount: 1980,
      category_id: "TODO_CATEGORY_ID",
      payment_method_id: "TODO_PAYMENT_METHOD_ID",
      start_date: today.beginning_of_month.iso8601
    }
  end

  describe "POST /api/v1/recurring_records" do
    it "creates a recurring record successfully" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      expect(last_response.status).to eq(201)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to be_a(String)
    end

    it "creates a recurring record with total_count" do
      post "/api/v1/recurring_records", recurring_params.merge(total_count: 12), auth_header
      expect(last_response.status).to eq(201)
    end
  end

  describe "GET /api/v1/recurring_records" do
    it "returns created recurring record in the list" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      created_id = json_body[:id]

      get "/api/v1/recurring_records", {}, auth_header
      expect(last_response.status).to eq(200)
      ids = json_body[:recurring_records].map { |r| r[:id] }
      expect(ids).to include(created_id)
    end

    it "returns recurring record with generated_count" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      created_id = json_body[:id]

      get "/api/v1/recurring_records", {}, auth_header
      record = json_body[:recurring_records].find { |r| r[:id] == created_id }
      expect(record).to have_key(:generated_count)
      expect(record[:generated_count]).to eq(0)
    end
  end

  describe "PUT /api/v1/recurring_records/:id" do
    it "updates a recurring record" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      created_id = json_body[:id]

      put "/api/v1/recurring_records/#{created_id}",
          recurring_params.merge(title: "Updated Title", amount: 2980), auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:status]).to eq("success")
    end
  end

  describe "DELETE /api/v1/recurring_records/:id" do
    it "deletes a recurring record" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      created_id = json_body[:id]

      delete "/api/v1/recurring_records/#{created_id}", {}, auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:status]).to eq("success")
    end
  end

  describe "POST /api/v1/recurring_records/:id/generate" do
    it "generates a finance record for the given month" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      recurring_id = json_body[:id]

      year = today.year
      month = today.month == 12 ? 1 : today.month + 1
      year += 1 if today.month == 12

      post "/api/v1/recurring_records/#{recurring_id}/generate",
           { year:, month: }, auth_header
      expect(last_response.status).to eq(201)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to be_a(String)
    end

    it "returns 409 when already generated for the same month" do
      post "/api/v1/recurring_records", recurring_params, auth_header
      recurring_id = json_body[:id]

      year = today.year
      month = today.month == 12 ? 1 : today.month + 1
      year += 1 if today.month == 12

      post "/api/v1/recurring_records/#{recurring_id}/generate",
           { year:, month: }, auth_header
      expect(last_response.status).to eq(201)

      post "/api/v1/recurring_records/#{recurring_id}/generate",
           { year:, month: }, auth_header
      expect(last_response.status).to eq(409)
    end

    it "returns 409 when total_count is reached" do
      post "/api/v1/recurring_records", recurring_params.merge(total_count: 1), auth_header
      recurring_id = json_body[:id]

      post "/api/v1/recurring_records/#{recurring_id}/generate",
           { year: today.year, month: today.month == 12 ? 1 : today.month + 1 }, auth_header
      expect(last_response.status).to eq(201)

      next_month = today.month == 11 ? 1 : today.month + 2
      next_year = (today.month >= 11) ? today.year + 1 : today.year
      post "/api/v1/recurring_records/#{recurring_id}/generate",
           { year: next_year, month: next_month }, auth_header
      expect(last_response.status).to eq(409)
    end
  end
end
