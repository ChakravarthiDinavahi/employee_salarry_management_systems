import { api } from './client'
import type { SalaryInsightsPayload } from '../types/insights'

export async function fetchSalaryInsights(): Promise<SalaryInsightsPayload> {
  const { data } = await api.get<{ data: SalaryInsightsPayload }>(
    '/api/v1/salary_insights',
  )
  return data.data
}
