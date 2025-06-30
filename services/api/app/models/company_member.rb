class CompanyMember < ApplicationRecord
  # Soft delete functionality
  include Discard::Model

  # Associations
  belongs_to :profile, class_name: "UserProfile"
  belongs_to :company
  belongs_to :access_role, class_name: "AccessRole", optional: true

  # Validations
  validates :invited_at, presence: true
  validates :profile_id, uniqueness: { scope: :company_id }
  validate :joined_at_after_invited_at, if: :joined_at?

  # Scopes
  default_scope { where(company: Current.company) if Current.company }
  scope :active, -> { kept }
  scope :inactive, -> { discarded }
  scope :invited, -> { where(joined_at: nil) }
  scope :joined, -> { where.not(joined_at: nil) }

  # Callbacks
  before_validation :set_invited_at, on: :create

  private

  def set_invited_at
    self.invited_at ||= Time.current
  end

  def joined_at_after_invited_at
    return unless joined_at && invited_at
    return if joined_at > invited_at

    errors.add(:joined_at, "must be after invited_at")
  end
end