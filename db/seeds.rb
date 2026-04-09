# frozen_string_literal: true

# High-volume demo employees: bulk insert (not per-row `create!`).
# Reads name lists from lib/data/*.txt; set SKIP_EMPLOYEE_SEED=1 to skip.

return if ENV["SKIP_EMPLOYEE_SEED"].present?

require "benchmark"
require "activerecord-import"

SEED_COUNT = 10_000
DATA_DIR = Rails.root.join("lib/data")

JOB_TITLES = [
  "Software Engineer",
  "Senior Software Engineer",
  "Staff Software Engineer",
  "Engineering Manager",
  "VP of Engineering",
  "DevOps Engineer",
  "Site Reliability Engineer",
  "QA Engineer",
  "Data Engineer",
  "Data Scientist",
  "Machine Learning Engineer",
  "Product Owner",
  "Product Manager",
  "Program Manager",
  "Scrum Master",
  "UX Designer",
  "UI Designer",
  "HR Manager",
  "HR Business Partner",
  "Talent Acquisition Lead",
  "People Operations Specialist",
  "Finance Analyst",
  "Financial Controller",
  "Accountant",
  "Sales Director",
  "Account Executive",
  "Customer Success Manager",
  "Marketing Manager",
  "Content Strategist",
  "Brand Manager",
  "Legal Counsel",
  "Office Administrator",
  "Business Analyst",
  "Technical Support Lead",
  "Security Engineer",
  "Solutions Architect",
  "IT Administrator",
  "Operations Manager",
  "Supply Chain Analyst",
  "Facilities Manager"
].freeze

COUNTRIES = [
  "United States",
  "United Kingdom",
  "Canada",
  "Germany",
  "France",
  "Spain",
  "Italy",
  "Netherlands",
  "Sweden",
  "Norway",
  "Denmark",
  "Finland",
  "Switzerland",
  "Ireland",
  "Poland",
  "India",
  "Japan",
  "South Korea",
  "Singapore",
  "Australia",
  "New Zealand",
  "Brazil",
  "Mexico",
  "Argentina",
  "South Africa",
  "Nigeria",
  "Israel",
  "United Arab Emirates",
  "Portugal",
  "Belgium",
  "Austria",
  "Czech Republic",
  "Hungary",
  "Romania",
  "Turkey",
  "Egypt",
  "Kenya",
  "Chile",
  "Colombia",
  "Malaysia",
  "Indonesia",
  "Philippines",
  "Vietnam",
  "Thailand",
  "Taiwan",
  "Hong Kong SAR"
].freeze

def load_name_lines(path)
  raise "Missing #{path}" unless File.file?(path)

  File.read(path, encoding: "UTF-8").split(/\r?\n/).map(&:strip).reject(&:empty?).uniq
end

first_names = load_name_lines(DATA_DIR.join("first_names.txt"))
last_names = load_name_lines(DATA_DIR.join("last_names.txt"))

if first_names.empty? || last_names.empty?
  raise "first_names.txt and last_names.txt must each contain at least one non-empty line"
end

# SQLite often limits bound parameters per statement (~999). Eight columns → batch ≤ 120.
IMPORT_BATCH_SIZE = 120

columns = %i[first_name last_name job_title salary country email created_at updated_at]
now = Time.current
rng = Random.new(42)

rows = Array.new(SEED_COUNT) do |i|
  fn = first_names.sample(random: rng)
  ln = last_names.sample(random: rng)
  title = JOB_TITLES.sample(random: rng)
  country = COUNTRIES.sample(random: rng)
  # Rough bands by role seniority keywords (still fast: no extra DB calls)
  base =
    if title.include?("VP") || title.include?("Director")
      rng.rand(140_000.0..260_000.0)
    elsif title.include?("Senior") || title.include?("Staff") || title.include?("Lead")
      rng.rand(95_000.0..185_000.0)
    elsif title.include?("Manager") || title.include?("Controller") || title.include?("Counsel")
      rng.rand(85_000.0..165_000.0)
    else
      rng.rand(42_000.0..135_000.0)
    end
  salary = BigDecimal(base.round(2).to_s).round(2)
  email = format("employee.%05d@seed.example.com", i + 1)

  [ fn, ln, title, salary, country, email, now, now ]
end

elapsed = Benchmark.realtime do
  ActiveRecord::Base.transaction do
    Employee.delete_all
    Employee.import columns, rows, validate: false, batch_size: IMPORT_BATCH_SIZE, timestamps: false
  end
end

puts format("Seeded %d employees in %.3fs", SEED_COUNT, elapsed)
