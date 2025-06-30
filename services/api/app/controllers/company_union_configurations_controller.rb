class CompanyUnionConfigurationsController < ApplicationController
  before_action :set_company
  before_action :set_company_union_configuration, only: [:show, :update, :destroy]

  def index
    config = @company.company_union_configuration
    if config.nil?
      config = CompanyUnionConfiguration.new
      config.company = @company
    end
    @company_union_configurations = config ? policy_scope([config]) : []
    authorize CompanyUnionConfiguration
    render :show
  end

  def show
    authorize @company_union_configuration
    render :show
  end

  def upsert
    @company = Company.find(params[:company_id])

    @company_union_configuration = @company.company_union_configuration ||
                                  @company.build_company_union_configuration
    authorize @company_union_configuration

    if @company_union_configuration.update(company_union_configuration_params)
      @message = @company_union_configuration.persisted? ? "Company union configuration saved successfully" : "Created new company union configuration"
      render :show, status: :ok
    else
      render json: { status: "error", message: @company_union_configuration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    upsert
  end

  def update
    upsert
  end

  def show
    @company_union_configuration = @company.company_union_configuration
    authorize @company_union_configuration
    @message = "Company union configuration retrieved successfully"
    render :show
  end

  def destroy
    authorize @company_union_configuration
    @company_union_configuration.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_company_union_configuration
    @company_union_configuration = @company.company_union_configuration
  end

  def company_union_configuration_params
    params.require(:company_union_configuration).permit(:union_type, :union_name, :agreement_type, :active, agreement_type_configuration: {})
  end
end
