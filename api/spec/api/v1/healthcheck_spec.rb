# frozen_string_literal: true

RSpec.describe "GET /api/healthcheck" do
  it "returns healthy" do
    get "/api/healthcheck"
    expect(last_response.status).to eq(200)
    expect(json_body).to eq(status: "healthy")
  end
end
