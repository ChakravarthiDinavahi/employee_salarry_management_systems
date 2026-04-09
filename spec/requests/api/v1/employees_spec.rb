# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  describe "GET /api/v1/employees" do
    it "returns JSON with pagination meta" do
      get "/api/v1/employees", headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")

      body = JSON.parse(response.body)
      expect(body["data"]).to eq([])
      expect(body["meta"]).to include(
        "page" => 1,
        "pages" => 1,
        "count" => 0,
        "items" => 25
      )
    end
  end
end
