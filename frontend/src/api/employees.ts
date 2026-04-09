import { api } from './client'
import type { Employee, EmployeeInput, PaginatedEmployees } from '../types/employee'

export async function fetchEmployees(params: {
  q?: string
  page?: number
  limit?: number
}): Promise<PaginatedEmployees> {
  const { data } = await api.get<PaginatedEmployees>('/api/v1/employees', {
    params,
  })
  return data
}

export async function createEmployee(
  input: EmployeeInput,
): Promise<Employee> {
  const { data } = await api.post<{ data: Employee }>('/api/v1/employees', {
    employee: input,
  })
  return data.data
}

export async function updateEmployee(
  id: number,
  input: EmployeeInput,
): Promise<Employee> {
  const { data } = await api.patch<{ data: Employee }>(
    `/api/v1/employees/${id}`,
    { employee: input },
  )
  return data.data
}

export async function deleteEmployee(id: number): Promise<void> {
  await api.delete(`/api/v1/employees/${id}`)
}
