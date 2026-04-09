class SalaryInsightsController < ApplicationController
  def index
    query = SalaryStatsQuery.new
    @avg_by_country = query.average_by_country
    @min_max_by_country = query.min_max_by_country

    @avg_by_title_country = query.avg_by_job_title_and_country
      .sort_by { |_, v| -v.to_f }
      .first(18)
      .to_h
      .transform_keys { |(title, country)| "#{title} — #{country}" }
  end
end
