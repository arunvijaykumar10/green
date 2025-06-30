class BankConfig < ApplicationRecord
  belongs_to :company

  validates :company, presence: true
  validates :bank_name, :account_number, :routing_number_ach, :routing_number_wire, :account_type, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :authorized, inclusion: { in: [true, false] }
  validates :routing_number_ach, format: { with: /\A\d{9}\z/, message: "must be 9 digits" }
  validates :routing_number_wire, format: { with: /\A\d{9}\z/, message: "must be 9 digits" }
  validates :account_type, inclusion: { in: %w[checking savings] }

  def complete?
    bank_name.present? && account_number.present? && routing_number_ach.present? && routing_number_wire.present? && account_type.present?
  end

  # Scopes
  scope :active, -> { where(active: true) }
  scope :approved, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false) }
end