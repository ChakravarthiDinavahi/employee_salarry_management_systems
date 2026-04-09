json.extract! employee, :id, :first_name, :last_name, :job_title, :salary, :country, :email, :created_at, :updated_at
json.url employee_url(employee, format: :json)
