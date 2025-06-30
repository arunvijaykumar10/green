class Tenant < ApplicationRecord
  # Soft delete functionality
  include Discard::Model
  has_many :companies

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  # Scopes
  scope :active, -> { where(discarded_at: nil) }

  def discard
    update(discarded_at: Time.now)
  end

  def active?
    discarded_at.nil?
  end

  private
  def generate_code
    return if code.present?
    self.code = name.parameterize.underscore if name.present?
  end
end
