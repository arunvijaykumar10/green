class CompanyReviewsController < ApplicationController
  before_action :set_company_review, only: [:show, :update, :approve, :reject]

  def index
    @company_reviews = policy_scope(CompanyReview.pending.includes(:company))
    authorize CompanyReview
    render :index
  end

  def show
    authorize @company_review
    render :show
  end

  def update
    authorize @company_review
    if @company_review.update(company_review_params)
      render :show
    else
      @errors = @company_review.errors.full_messages
      render :error, status: :unprocessable_entity
    end
  end

  def approve
    authorize @company_review

    unless @company_review.status == "pending"
      @errors = ["Company review must be in pending status to approve"]
      render :error, status: :unprocessable_entity
      return
    end

    unless @company_review.company.valid?(:approval)
      @errors = @company_review.company.errors.full_messages
      render :error, status: :unprocessable_entity
      return
    end

    @company_review.update!(
      status: "approved",
      reviewed_by: Current.user_profile,
      reviewed_at: Time.current,
      review_notes: company_review_params[:review_notes]
    )
    CompanyApprovalJob.perform_later(@company_review)
    render :show
  end

  def reject
    authorize @company_review

    unless @company_review.status == "pending"
      @errors = ["Company review must be in pending status to reject"]
      render :error, status: :unprocessable_entity
      return
    end

    @company_review.update!(
      status: "rejected",
      reviewed_by: Current.user_profile,
      reviewed_at: Time.current,
      review_notes: company_review_params[:review_notes]
    )
    render :show
  end

  private

  def set_company_review
    @company_review = CompanyReview.find(params[:id])
  end

  def company_review_params
    params.require(:company_review).permit(:review_notes)
  end
end
