class CompanyReview < ApplicationRecord
  # Associations
  belongs_to :company
  belongs_to :reviewed_by, class_name: 'UserProfile', optional: true
  
  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }
  
  # Callbacks
  after_update :approve_company_records, if: -> { saved_change_to_status? && status == 'approved' }
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  
  def approve!
    update!(
      status: 'approved',
      reviewed_at: Time.current
    )
  end
  
  def reject!(notes = nil)
    update!(
      status: 'rejected',
      review_notes: notes,
      reviewed_at: Time.current
    )
  end
  
  private
  
  def approve_company_records
    CompanyApprovalJob.perform_later(company_id)
  end
end