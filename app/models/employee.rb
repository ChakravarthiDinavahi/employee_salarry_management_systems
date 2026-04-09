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
  validates :first_name, :last_name, :job_title, :country, :email, presence: true
  validates :salary, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def full_name
    [ first_name, last_name ].compact.join(" ")
  end

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
