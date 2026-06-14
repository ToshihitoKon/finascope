# frozen_string_literal: true

RSpec.describe "Records API" do
  before { stub_authenticated_user }

  let(:today) { Date.today }

  let(:record_params) do
    {
      title: "Test Record",
      type_id: 0,
      state_id: 0,
      description: "Test description",
      amount: 1000,
      category_id: "TODO_CATEGORY_ID",
      payment_method_id: "TODO_PAYMENT_METHOD_ID",
      date: today.iso8601
    }
  end

  let(:get_params) do
    {
      begin_date: today.beginning_of_month.iso8601,
      end_date: today.end_of_month.iso8601
    }
  end

  describe "POST /api/v1/records" do
    it "creates a record successfully" do
      post "/api/v1/records", record_params, auth_header
      expect(last_response.status).to eq(201)
      expect(json_body[:status]).to eq("success")
      expect(json_body[:id]).to be_a(String)
    end

    it "creates a record with recurring_group_id" do
      post "/api/v1/records", record_params.merge(recurring_group_id: "rr_test_id"), auth_header
      expect(last_response.status).to eq(201)
      created_id = json_body[:id]

      get "/api/v1/records", get_params, auth_header
      record = json_body[:records].find { |r| r[:id] == created_id }
      expect(record[:recurring_group_id]).to eq("rr_test_id")
    end

    it "defaults recurring_group_id to nil when not specified" do
      post "/api/v1/records", record_params, auth_header
      expect(last_response.status).to eq(201)
      created_id = json_body[:id]

      get "/api/v1/records", get_params, auth_header
      record = json_body[:records].find { |r| r[:id] == created_id }
      expect(record[:recurring_group_id]).to be_nil
    end
  end

  describe "GET /api/v1/records" do
    it "returns created record in the list" do
      post "/api/v1/records", record_params, auth_header
      created_id = json_body[:id]

      get "/api/v1/records", get_params, auth_header
      expect(last_response.status).to eq(200)
      ids = json_body[:records].map { |r| r[:id] }
      expect(ids).to include(created_id)
    end

    it "includes recurring_group_id field in response" do
      post "/api/v1/records", record_params, auth_header
      created_id = json_body[:id]

      get "/api/v1/records", get_params, auth_header
      record = json_body[:records].find { |r| r[:id] == created_id }
      expect(record).to have_key(:recurring_group_id)
    end

    it "filters by recurring=true" do
      post "/api/v1/records", record_params, auth_header
      post "/api/v1/records", record_params.merge(recurring_group_id: "rr_test_id"), auth_header
      recurring_id = json_body[:id]

      get "/api/v1/records", get_params.merge(recurring: true), auth_header
      expect(last_response.status).to eq(200)
      ids = json_body[:records].map { |r| r[:id] }
      expect(ids).to include(recurring_id)
      expect(json_body[:records].all? { |r| !r[:recurring_group_id].nil? }).to be true
    end
  end
end
