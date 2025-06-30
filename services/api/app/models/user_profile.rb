class UserProfile < ApplicationRecord
  # Soft delete functionality
  include Discard::Model

  # Associations
  has_one :user_credential, dependent: :destroy
  has_many :company_members, foreign_key: :profile_id, dependent: :destroy
  has_many :companies, through: :company_members
  has_many :company_access_logs

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: { scope: :discarded_at }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" }
  validates :phone_no, format: { with: /\A\+?\d+\z/, message: "only allows numbers and optional + prefix" }, allow_nil: true

  # Scopes
  scope :active, -> { kept }
  scope :inactive, -> { discarded }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def super_admin?
    super_admin
  end

  def admin?
    # Check if user has admin role in any company
    company_members.joins(:access_role).exists?(access_roles: { role_type: "admin" })
  end

  def employee?
    # Regular user/employee (not admin or super admin)
    !super_admin? && !admin?
  end

  def access_role_for_company(company)
    company_members.joins(:access_role).find_by(company: company)&.access_role
  end

  def access_role_name_for_company(company)
    access_role_for_company(company)&.name
  end
  # def accessible_record_ids_for(model_name)
  #   # Implement logic to determine which records this user can access
  #   # This will vary based on your application's requirements
  #   case model_name
  #   when 'Tenant'
  #     account_members.pluck(:account_id)
  #   when 'Company'
  #     company_members.pluck(:company_id)
  #   else
  #     []
  #   end
  # end
end
