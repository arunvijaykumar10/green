class UserCredential < ApplicationRecord
  # Associations
  belongs_to :user_profile

  # Validations
  validates :subject, presence: true, uniqueness: { scope: :user_profile_id }
  validates :user_profile, uniqueness: true

  # Callbacks
  before_create :set_first_login_at

  # Scopes
  scope :with_first_login, -> { where.not(first_login_at: nil) }
  scope :without_first_login, -> { where(first_login_at: nil) }

  private

  def set_first_login_at
    self.first_login_at ||= Time.current
  end
end
