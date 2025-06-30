class CompanyAccessLog < ApplicationRecord
  belongs_to :user_profile
  belongs_to :company

  # Validations for data integrity
  validates :user_profile, presence: true
  validates :company, presence: true
  validates :action_type, presence: true, inclusion: { in: ["login", "switch_company", "view_dashboard", "logout"] }
end
