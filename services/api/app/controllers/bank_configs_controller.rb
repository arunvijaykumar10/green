class BankConfigsController < ApplicationController
  before_action :set_company
  before_action :set_bank_config, only: [:show, :update, :destroy]

  def index
    @bank_config = policy_scope(@company.bank_config)
    authorize BankConfig
    render :show
  end

  def show
    @bank_config = @company.bank_config || @company.build_bank_config
    authorize @bank_config
    render :show
  end

  def upsert
    @company = Company.find(params[:company_id])

    @bank_config = @company.bank_config ||
                                  @company.build_bank_config
    authorize @bank_config

    if @bank_config.update(bank_config_params)
      @message = @bank_config.persisted? ? "Bank configuration saved successfully" : "Created new company bank configuration"
      render :show, status: :ok
    else
      render json: { status: "error", message: @bank_config.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    upsert
  end

  def update
    upsert
  end

  def destroy
    authorize @bank_config
    @bank_config.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_bank_config
    @bank_config = @company.bank_config
  end

  def bank_config_params
    params.require(:bank_config).permit(:bank_name, :account_number, :routing_number_ach, :routing_number_wire, :account_type, :active, :authorized)
  end
end
