# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee do
  def valid_attributes
    {
      first_name: "Jane",
      last_name: "Doe",
      job_title: "Engineer",
      country: "United States",
      email: "jane.#{SecureRandom.hex(4)}@example.com",
      salary: BigDecimal("85000.50")
    }
  end

  describe "validations" do
    it "is valid with all required attributes" do
      expect(Employee.new(valid_attributes)).to be_valid
    end

    it "requires first_name" do
      employee = Employee.new(valid_attributes.merge(first_name: ""))
      expect(employee).not_to be_valid
      expect(employee.errors[:first_name]).to include("can't be blank")
    end

    it "requires salary to be non-negative" do
      employee = Employee.new(valid_attributes.merge(salary: BigDecimal("-1")))
      expect(employee).not_to be_valid
      expect(employee.errors[:salary]).to include("must be greater than or equal to 0")
    end
  end

  describe "#full_name" do
    it "joins first and last name with a space" do
      employee = described_class.new(first_name: "Ada", last_name: "Lovelace")
      expect(employee.full_name).to eq("Ada Lovelace")
    end
  end

  describe ".search" do
    before { Employee.delete_all }

    it "returns all rows when the query is blank" do
      Employee.create!(valid_attributes.merge(email: "blank1@example.com"))
      expect(described_class.search("").count).to eq(1)
      expect(described_class.search("   ").count).to eq(1)
    end

    it "matches case-insensitively on name fields" do
      Employee.create!(valid_attributes.merge(first_name: "Zebra", email: "z1@example.com"))
      expect(described_class.search("zebra").count).to eq(1)
    end

    it "matches email substring" do
      Employee.create!(valid_attributes.merge(email: "findme@example.com"))
      expect(described_class.search("findme").count).to eq(1)
    end
  end
end
