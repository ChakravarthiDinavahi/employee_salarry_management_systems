# frozen_string_literal: true

require "rails_helper"

RSpec.describe SalaryStatsQuery do
  def bd(amount)
    BigDecimal(amount.to_s)
  end

  before do
    Employee.delete_all
  end

  describe "#average_by_country" do
    it "returns the arithmetic mean salary per country computed in SQL" do
      Employee.create!(
        first_name: "A", last_name: "One", job_title: "Engineer", salary: bd("100000.00"),
        country: "United States", email: "a1@example.com"
      )
      Employee.create!(
        first_name: "B", last_name: "Two", job_title: "Engineer", salary: bd("200000.00"),
        country: "United States", email: "b2@example.com"
      )
      Employee.create!(
        first_name: "C", last_name: "Three", job_title: "Analyst", salary: bd("30000.00"),
        country: "United Kingdom", email: "c3@example.com"
      )

      query = described_class.new
      averages = query.average_by_country

      expect(averages["United States"]).to eq bd("150000.00")
      expect(averages["United Kingdom"]).to eq bd("30000.00")
    end

    it "respects the relation scope" do
      Employee.create!(
        first_name: "A", last_name: "X", job_title: "Engineer", salary: bd("50000.00"),
        country: "Canada", email: "x1@example.com"
      )
      Employee.create!(
        first_name: "B", last_name: "Y", job_title: "Engineer", salary: bd("150000.00"),
        country: "Canada", email: "y2@example.com"
      )

      scoped = Employee.where("salary < ?", bd("100000.00"))
      averages = described_class.new(scoped).average_by_country

      expect(averages["Canada"]).to eq bd("50000.00")
    end

    it "memoizes the result" do
      Employee.create!(
        first_name: "A", last_name: "Z", job_title: "Role", salary: bd("40000.00"),
        country: "France", email: "z1@example.com"
      )

      query = described_class.new
      first = query.average_by_country
      Employee.create!(
        first_name: "B", last_name: "Z", job_title: "Role", salary: bd("60000.00"),
        country: "France", email: "z2@example.com"
      )
      second = query.average_by_country

      expect(second.object_id).to eq(first.object_id)
      expect(second["France"]).to eq bd("40000.00")
    end
  end

  describe "#min_max_by_country" do
    it "returns MIN and MAX salary per country from the database" do
      Employee.create!(
        first_name: "A", last_name: "M", job_title: "Engineer", salary: bd("72000.50"),
        country: "Germany", email: "m1@example.com"
      )
      Employee.create!(
        first_name: "B", last_name: "M", job_title: "Manager", salary: bd("108000.75"),
        country: "Germany", email: "m2@example.com"
      )
      Employee.create!(
        first_name: "C", last_name: "M", job_title: "Intern", salary: bd("36000.25"),
        country: "Germany", email: "m3@example.com"
      )

      result = described_class.new.min_max_by_country["Germany"]

      expect(result[:min]).to eq bd("36000.25")
      expect(result[:max]).to eq bd("108000.75")
    end

    it "memoizes the result" do
      Employee.create!(
        first_name: "P", last_name: "Q", job_title: "Job", salary: bd("10.00"),
        country: "Spain", email: "pq1@example.com"
      )

      query = described_class.new
      first = query.min_max_by_country
      Employee.create!(
        first_name: "P", last_name: "Q2", job_title: "Job", salary: bd("99.00"),
        country: "Spain", email: "pq2@example.com"
      )

      expect(query.min_max_by_country.object_id).to eq(first.object_id)
      expect(query.min_max_by_country["Spain"][:max]).to eq bd("10.00")
    end
  end

  describe "#avg_by_job_title_and_country" do
    it "averages salary grouped by job title and country" do
      Employee.create!(
        first_name: "A", last_name: "S", job_title: "Software Engineer", salary: bd("90000.00"),
        country: "India", email: "s1@example.com"
      )
      Employee.create!(
        first_name: "B", last_name: "S", job_title: "Software Engineer", salary: bd("110000.00"),
        country: "India", email: "s2@example.com"
      )
      Employee.create!(
        first_name: "C", last_name: "S", job_title: "HR Manager", salary: bd("50000.00"),
        country: "India", email: "s3@example.com"
      )
      Employee.create!(
        first_name: "D", last_name: "S", job_title: "Software Engineer", salary: bd("40000.00"),
        country: "Japan", email: "s4@example.com"
      )

      avgs = described_class.new.avg_by_job_title_and_country

      key_se_india = [ "Software Engineer", "India" ]
      expect(avgs[key_se_india]).to eq bd("100000.00")
      expect(avgs[[ "HR Manager", "India" ]]).to eq bd("50000.00")
      expect(avgs[[ "Software Engineer", "Japan" ]]).to eq bd("40000.00")
    end

    it "respects the relation scope" do
      Employee.create!(
        first_name: "F", last_name: "G", job_title: "Product Owner", salary: bd("80000.00"),
        country: "Brazil", email: "g1@example.com"
      )
      Employee.create!(
        first_name: "F", last_name: "G2", job_title: "Product Owner", salary: bd("120000.00"),
        country: "Brazil", email: "g2@example.com"
      )

      scoped = Employee.where("salary < ?", 100_000)
      avgs = described_class.new(scoped).avg_by_job_title_and_country

      expect(avgs[[ "Product Owner", "Brazil" ]]).to eq bd("80000.00")
    end

    it "memoizes the result" do
      Employee.create!(
        first_name: "M", last_name: "N", job_title: "Designer", salary: bd("50.00"),
        country: "Italy", email: "mn1@example.com"
      )

      query = described_class.new
      first = query.avg_by_job_title_and_country
      Employee.create!(
        first_name: "M", last_name: "N2", job_title: "Designer", salary: bd("150.00"),
        country: "Italy", email: "mn2@example.com"
      )

      expect(query.avg_by_job_title_and_country.object_id).to eq(first.object_id)
      expect(query.avg_by_job_title_and_country[[ "Designer", "Italy" ]]).to eq bd("50.00")
    end
  end
end
