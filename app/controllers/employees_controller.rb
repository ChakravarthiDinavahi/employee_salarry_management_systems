class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show edit update destroy]

  def index
    assign_table!
  end

  def show
  end

  def new
    @employee = Employee.new
    @q = params[:q].to_s
  end

  def edit
    @q = params[:q].to_s
  end

  def create
    @employee = Employee.new(employee_params)
    @q = params[:q].to_s.strip

    if @employee.save
      respond_to do |format|
        format.html { redirect_to employees_path(q: @q), notice: "Employee was successfully created." }
        format.turbo_stream do
          assign_table!
          flash.now[:notice] = "Employee was successfully created."
          render :refresh
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "employee_modal",
            partial: "employees/modal",
            locals: { employee: @employee, title: "New employee", q: @q }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def update
    @q = params[:q].to_s.strip

    if @employee.update(employee_params)
      respond_to do |format|
        format.html { redirect_to employees_path(q: @q), notice: "Employee was successfully updated.", status: :see_other }
        format.turbo_stream do
          assign_table!
          flash.now[:notice] = "Employee was successfully updated."
          render :refresh
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "employee_modal",
            partial: "employees/modal",
            locals: { employee: @employee, title: "Edit employee", q: @q }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @q = params[:q].to_s.strip
    @employee.destroy!

    respond_to do |format|
      format.html { redirect_to employees_path(q: @q), notice: "Employee was successfully destroyed.", status: :see_other }
      format.turbo_stream do
        assign_table!
        flash.now[:notice] = "Employee was successfully destroyed."
        render :refresh
      end
    end
  end

  private

  def assign_table!
    @q = params[:q].to_s.strip
    scoped = Employee.search(@q).order(:id)
    @pagy, @employees = pagy(:offset, scoped, limit: 25)
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :job_title, :salary, :country, :email)
  end
end
