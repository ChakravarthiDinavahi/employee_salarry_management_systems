# frozen_string_literal: true

module Api
  module V1
    class SalaryInsightsController < BaseController
      def index
        query = SalaryStatsQuery.new
        avg_country = stringify_money_hash(query.average_by_country)
        min_max = query.min_max_by_country.transform_values do |mm|
          { min: mm[:min].to_s("F"), max: mm[:max].to_s("F") }
        end

        by_title_country = query.avg_by_job_title_and_country.map do |(title, country), avg|
          {
            job_title: title,
            country: country,
            average: avg.to_s("F")
          }
        end

        render json: {
          data: {
            average_salary_by_country: avg_country,
            min_max_salary_by_country: min_max,
            average_salary_by_job_title_and_country: by_title_country
          }
        }
      end

      private

      def stringify_money_hash(hash)
        hash.transform_values { |v| v&.to_s("F") }
      end
    end
  end
end
