export type Employee = {
  id: number
  first_name: string
  last_name: string
  full_name: string
  job_title: string
  country: string
  salary: string | null
  email: string
  created_at?: string
  updated_at?: string
}

export type PaginationMeta = {
  page: number
  pages: number
  count: number
  items: number
  from: number
  to: number
}

export type PaginatedEmployees = {
  data: Employee[]
  meta: PaginationMeta
}

export type EmployeeInput = {
  first_name: string
  last_name: string
  job_title: string
  country: string
  email: string
  salary: string
}
