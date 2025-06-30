class PayrollConfig < ApplicationRecord
  belongs_to :company

  validates :company, presence: true
  validates :frequency, presence: true
  validates :period, presence: true
  validates :start_date, presence: true
  validates :check_start_number, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :approved, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false) }

end