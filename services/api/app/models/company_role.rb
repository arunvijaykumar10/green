class CompanyRole < ApplicationRecord
  # Soft delete functionality
  include Discard::Model

  # Associations
  belongs_to :company
  has_many :company_members, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :company_id }

  # Scopes
  scope :active, -> { kept }
  scope :inactive, -> { discarded }
end