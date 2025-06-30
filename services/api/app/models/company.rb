class Company < ApplicationRecord
  # Soft delete functionality
  include Discard::Model

  # Associations
  belongs_to :tenant
  belongs_to :owned_by, class_name: "UserProfile"
  has_many :company_members, dependent: :destroy
  has_many :user_profiles, through: :company_members, source: :profile
  has_one :bank_config, dependent: :destroy
  accepts_nested_attributes_for :bank_config, update_only: true
  has_one :company_union_configuration, dependent: :destroy
  accepts_nested_attributes_for :company_union_configuration, update_only: true
  has_many :addresses, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true
  has_one :payroll_config, dependent: :destroy
  accepts_nested_attributes_for :payroll_config, update_only: true
  has_one :company_review, dependent: :destroy
  has_one :primary_address, -> { where(address_type: "primary").active }, class_name: "Address", as: :addressable
  has_one_attached :signature
  has_one_attached :secondary_signature

  # Validations
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :signature_type, inclusion: { in: %w[single double] }, on: :submit_for_review
  validates :primary_address, presence: true, on: :submit_for_review
  validates :signature, presence: true, on: :submit_for_review
  validates :secondary_signature, presence: true, on: :submit_for_review, if: -> { signature_type == "double" }

  validates :name, :code, :fein, :company_type, :nys_no, :phone, presence: true, on: :approval
  validates :primary_address, presence: true, on: :approval
  validates :signature, presence: true, on: :approval
  validates :secondary_signature, presence: true, on: :approval, if: -> { signature_type == "double" }
  validate :validate_all_referenced_tables_complete, on: :approval

  # Custom validation context
  def validate_for_review
    valid?(:submit_for_review)
  end

  def submit_for_review!
    return false unless validate_for_review

    create_company_review!(
      status: "pending",
      submitted_at: Time.current
    )
  end

  def review_status_info
    return { status: 'not_submitted', notes: nil } unless company_review
    {
      status: company_review.status,
      notes: company_review.review_notes,
      reviewed_at: company_review.reviewed_at,
      reviewed_by: company_review.reviewed_by&.full_name
    }
  end

  private

  def validate_all_referenced_tables_complete
    errors.add(:bank_config, "must be present and complete") if bank_config.blank? || !bank_config.complete?
    errors.add(:payroll_config, "must be present and complete") if payroll_config.blank?
    errors.add(:addresses, "must have at least one address") if addresses.blank?
    errors.add(:company_union_configuration, "must have union configuration") if company_union_configuration.blank?
    errors.add(:signature, "must have a signature") if signature.blank?
    errors.add(:secondary_signature, "must have a secondary signature") if secondary_signature.blank? && signature_type == "double"
  end

  # Scopes
  scope :active, -> { kept }
  scope :approved, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false) }
end
