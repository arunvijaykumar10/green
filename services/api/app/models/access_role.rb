class AccessRole < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :role_type, presence: true, inclusion: { in: %w[admin employee] }
  validates :category, inclusion: { in: %w[union non-union], allow_nil: true }

  # Scopes
  scope :admin_roles, -> { where(role_type: 'admin') }
  scope :employee_roles, -> { where(role_type: 'employee') }
  scope :union_roles, -> { where(category: 'union') }
  scope :non_union_roles, -> { where(category: 'non-union') }

  # Associations
  has_many :company_members
  has_many :user_profiles, through: :company_members, source: :profile
end