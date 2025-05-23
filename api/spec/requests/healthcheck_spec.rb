require 'spec_helper'

RSpec.describe "Healthcheck API" do
  it "returns a healthy status" do
    get "/api/healthcheck"
    
    expect(last_response.status).to eq(200)
    
    json_response = JSON.parse(last_response.body)
    expect(json_response['status']).to eq('healthy')
  end
end
