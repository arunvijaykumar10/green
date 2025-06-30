class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :update, :submit_for_review, :review_status]

  def index
    @companies = policy_scope(Company)
    authorize Company
    render :index
  end

  def show
    authorize @company
    render :show
  end

  def update
    authorize @company
    if @company.update(company_params)
      render :show
    else
      @errors = @company.errors.full_messages
      render :error, status: :unprocessable_entity
    end
  end

  def submit_for_review
    authorize @company
    @company.submit_for_review!
    render json: {
      status: "success",
      message: "Company submitted for review"
    }
  end

  def review_status
    authorize @company, :review_status?
    @status = @company&.review_status_info
    render :review_status
  end

  private

  def set_company
    if Current.user_profile&.super_admin?
      @company = Company.find(params[:id])
    else
      @company = Current.company
    end
  end

  def company_params
    params.require(:company).permit(
      :name, :code, :fein, :company_type, :nys_no, :phone, :email,:signature_type, :signature, :secondary_signature,
      addresses_attributes: [:id, :address_type, :address_line_1, :address_line_2, :city, :state, :zip_code, :country, :active_from, :active_until, :_destroy]
    )
  end
end