# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Employees", type: :request do
  def employee_attrs(overrides = {})
    {
      first_name: "Pat",
      last_name: "Lee",
      job_title: "Analyst",
      country: "Canada",
      email: "pat.#{SecureRandom.hex(4)}@example.com",
      salary: BigDecimal("72000.00")
    }.merge(overrides)
  end

  before { Employee.delete_all }

  describe "GET /api/v1/employees" do
    it "returns JSON with pagination meta" do
      get "/api/v1/employees", as: :json

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")

      body = json_response
      expect(body["data"]).to eq([])
      expect(body["meta"]).to include(
        "page" => 1,
        "pages" => 1,
        "count" => 0,
        "items" => 25
      )
    end

    it "filters by search query param q" do
      Employee.create!(employee_attrs.merge(first_name: "UniqueSearch", email: "u1@example.com"))
      Employee.create!(employee_attrs.merge(first_name: "Other", email: "o2@example.com"))

      get "/api/v1/employees", params: { q: "uniquesearch" }, as: :json

      expect(response).to have_http_status(:ok)
      names = json_response["data"].map { |row| row["first_name"] }
      expect(names).to eq([ "UniqueSearch" ])
    end

    it "respects limit and returns meta.items" do
      3.times do |i|
        Employee.create!(employee_attrs.merge(email: "limit#{i}@example.com"))
      end

      get "/api/v1/employees", params: { limit: 2, page: 1 }, as: :json

      expect(response).to have_http_status(:ok)
      body = json_response
      expect(body["data"].size).to eq(2)
      expect(body["meta"]["items"]).to eq(2)
      expect(body["meta"]["count"]).to eq(3)
    end
  end

  describe "GET /api/v1/employees/:id" do
    it "returns the employee payload" do
      employee = Employee.create!(employee_attrs.merge(email: "show@example.com"))

      get "/api/v1/employees/#{employee.id}", as: :json

      expect(response).to have_http_status(:ok)
      row = json_response["data"]
      expect(row["id"]).to eq(employee.id)
      expect(row["full_name"]).to eq("#{employee.first_name} #{employee.last_name}")
      expect(row["salary"]).to eq(employee.salary.to_s("F"))
    end

    it "returns 404 JSON when missing" do
      get "/api/v1/employees/999_999", as: :json

      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Not found")
    end
  end

  describe "POST /api/v1/employees" do
    it "creates an employee and returns 201" do
      attrs = employee_attrs.merge(email: "new@example.com")

      expect do
        post "/api/v1/employees", params: { employee: attrs }, as: :json
      end.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)
      row = json_response["data"]
      expect(row["email"]).to eq("new@example.com")
      expect(row["full_name"]).to eq("Pat Lee")
    end

    it "returns 422 with errors when invalid" do
      post "/api/v1/employees",
           params: { employee: employee_attrs.merge(first_name: "", email: "bad@example.com") },
           as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json_response["errors"]).to be_an(Array)
      expect(json_response["errors"].join).to include("First name")
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    it "updates the employee" do
      employee = Employee.create!(employee_attrs.merge(email: "patch@example.com"))

      patch "/api/v1/employees/#{employee.id}",
            params: { employee: { job_title: "Principal Analyst" } },
            as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response["data"]["job_title"]).to eq("Principal Analyst")
      expect(employee.reload.job_title).to eq("Principal Analyst")
    end

    it "returns 422 when invalid" do
      employee = Employee.create!(employee_attrs.merge(email: "badpatch@example.com"))

      patch "/api/v1/employees/#{employee.id}",
            params: { employee: { salary: BigDecimal("-5") } },
            as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json_response["errors"]).to be_an(Array)
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    it "removes the employee and returns no content" do
      employee = Employee.create!(employee_attrs.merge(email: "del@example.com"))

      expect do
        delete "/api/v1/employees/#{employee.id}", as: :json
      end.to change(Employee, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
