# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  job_title  :string
#  salary     :decimal(12, 2)
#  country    :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Employee < ApplicationRecord
  scope :search, lambda { |query|
    q = query.to_s.strip
    if q.blank?
      all
    else
      pattern = "%#{Employee.sanitize_sql_like(q.downcase)}%"
      where(
        <<~SQL.squish,
          LOWER(first_name) LIKE :p OR LOWER(last_name) LIKE :p OR
          LOWER(email) LIKE :p OR LOWER(job_title) LIKE :p OR LOWER(country) LIKE :p
        SQL
        p: pattern
      )
    end
  }
end
