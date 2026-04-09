# frozen_string_literal: true

# Aggregates salary metrics in the database (GROUP BY + AVG / MIN / MAX), not in Ruby.
# Memoizes each result per instance so repeated calls do not re-hit the DB.
class SalaryStatsQuery
  def initialize(relation = Employee.all)
    @relation = relation
  end

  # @return [Hash{String => BigDecimal}] country => average salary
  def average_by_country
    @average_by_country ||= load_average_by_country
  end

  # @return [Hash{String => Hash}] country => { min: BigDecimal, max: BigDecimal }
  def min_max_by_country
    @min_max_by_country ||= load_min_max_by_country
  end

  # @return [Hash{Array(String) => BigDecimal}] [job_title, country] => average salary
  def avg_by_job_title_and_country
    @avg_by_job_title_and_country ||= load_avg_by_job_title_and_country
  end

  private

  def load_average_by_country
    # SELECT country, AVG(salary) FROM employees ... GROUP BY country
    @relation.group(:country).average(:salary).transform_values { |v| cast_decimal(v) }
  end

  def load_min_max_by_country
    rows = @relation.reorder(nil).group(:country).pluck(
      :country,
      Arel.sql("MIN(salary)"),
      Arel.sql("MAX(salary)")
    )
    rows.to_h do |country, min_salary, max_salary|
      [
        country,
        { min: cast_decimal(min_salary), max: cast_decimal(max_salary) }
      ]
    end
  end

  def load_avg_by_job_title_and_country
    # SELECT job_title, country, AVG(salary) FROM employees ... GROUP BY job_title, country
    @relation.group(:job_title, :country).average(:salary).transform_values { |v| cast_decimal(v) }
  end

  def cast_decimal(value)
    return nil if value.nil?

    value.is_a?(BigDecimal) ? value : BigDecimal(value.to_s)
  end
end
