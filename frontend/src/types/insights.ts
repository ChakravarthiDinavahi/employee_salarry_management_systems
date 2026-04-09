export type SalaryInsightsPayload = {
  average_salary_by_country: Record<string, string>
  min_max_salary_by_country: Record<
    string,
    { min: string; max: string }
  >
  average_salary_by_job_title_and_country: Array<{
    job_title: string
    country: string
    average: string
  }>
}

export type SalaryInsightsResponse = {
  data: SalaryInsightsPayload
}
