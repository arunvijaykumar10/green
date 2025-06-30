class PayrollConfigsController < ApplicationController
  before_action :set_company
  before_action :set_payroll_config, only: [:show, :update, :destroy]

  def index
    @payroll_config = policy_scope(@company.payroll_config)
    authorize PayrollConfig
    render :index
  end

  def show
    @payroll_config = @company.payroll_config || @company.build_payroll_config
    authorize @payroll_config
    render :show
  end

  def upsert
    @company = Company.find(params[:company_id])

    @payroll_config = @company.payroll_config ||
                                  @company.build_payroll_config
    authorize @payroll_config

    if @payroll_config.update(payroll_config_params)
      @message = @payroll_config.persisted? ? "Company payroll configuration saved successfully" : "Created new company payroll configuration"
      render :show, status: :ok
    else
      render json: { status: "error", message: @payroll_config.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    upsert
  end

  def update
    upsert
  end

  def destroy
    authorize @payroll_config
    @payroll_config.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_payroll_config
    @payroll_config = @company.payroll_config
  end

  def payroll_config_params
    params.require(:payroll_config).permit(:frequency, :period, :start_date, :check_start_number, :active)
  end
end
