# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::SalaryInsights", type: :request do
  before { Employee.delete_all }

  describe "GET /api/v1/salary_insights" do
    it "returns aggregate payloads as JSON strings" do
      Employee.create!(
        first_name: "A",
        last_name: "One",
        job_title: "Engineer",
        salary: BigDecimal("100000.00"),
        country: "United States",
        email: "api-insights-1@example.com"
      )
      Employee.create!(
        first_name: "B",
        last_name: "Two",
        job_title: "Engineer",
        salary: BigDecimal("200000.00"),
        country: "United States",
        email: "api-insights-2@example.com"
      )

      get "/api/v1/salary_insights", as: :json

      expect(response).to have_http_status(:ok)
      payload = json_response["data"]

      expect(payload["average_salary_by_country"]["United States"]).to eq("150000.0")
      mm = payload["min_max_salary_by_country"]["United States"]
      expect(mm["min"]).to eq("100000.0")
      expect(mm["max"]).to eq("200000.0")

      row = payload["average_salary_by_job_title_and_country"].find do |r|
        r["job_title"] == "Engineer" && r["country"] == "United States"
      end
      expect(row["average"]).to eq("150000.0")
    end

    it "returns empty structures when there are no employees" do
      get "/api/v1/salary_insights", as: :json

      expect(response).to have_http_status(:ok)
      payload = json_response["data"]
      expect(payload["average_salary_by_country"]).to eq({})
      expect(payload["min_max_salary_by_country"]).to eq({})
      expect(payload["average_salary_by_job_title_and_country"]).to eq([])
    end
  end
end
