# frozen_string_literal: true

module Api
  module V1
    class EmployeesController < BaseController
      before_action :set_employee, only: %i[show update destroy]

      def index
        q = params[:q].to_s.strip
        scoped = Employee.search(q).order(:id)
        pagy, employees = pagy(:offset, scoped, limit: pagination_limit)
        render json: {
          data: employees.map { |e| employee_payload(e) },
          meta: pagination_meta(pagy)
        }
      end

      def show
        render json: { data: employee_payload(@employee) }
      end

      def create
        employee = Employee.new(employee_params)
        if employee.save
          render json: { data: employee_payload(employee) }, status: :created
        else
          render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @employee.update(employee_params)
          render json: { data: employee_payload(@employee) }
        else
          render json: { errors: @employee.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @employee.destroy!
        head :no_content
      end

      private

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def employee_params
        params.require(:employee).permit(:first_name, :last_name, :job_title, :salary, :country, :email)
      end

      def pagination_limit
        limit = params[:limit].to_i
        limit = 25 if limit <= 0 || limit > 100
        limit
      end

      def pagination_meta(pagy)
        {
          page: pagy.page,
          pages: pagy.last,
          count: pagy.count,
          items: pagy.limit,
          from: pagy.from,
          to: pagy.to
        }
      end

      def employee_payload(employee)
        {
          id: employee.id,
          first_name: employee.first_name,
          last_name: employee.last_name,
          full_name: employee.full_name,
          job_title: employee.job_title,
          country: employee.country,
          salary: employee.salary&.to_s("F"),
          email: employee.email,
          created_at: employee.created_at&.iso8601,
          updated_at: employee.updated_at&.iso8601
        }
      end
    end
  end
end
