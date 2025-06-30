class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :address_type, presence: true, inclusion: { in: %w[primary billing shipping] }
  validates :address_line_1, :city, :state, :zip_code, :active_from, presence: true
  validates :country, presence: true, inclusion: { in: %w[US CA] }

  # Scopes
  scope :primary, -> { where(address_type: 'primary') }
  scope :active, -> { where('active_from <= ? AND (active_until IS NULL OR active_until >= ?)', Time.current, Time.current) }

  # Callbacks
  before_save :handle_primary_address_change, if: -> { address_type == 'primary' && new_record? }

  private

  def handle_primary_address_change
    # Set active_until for current primary address
    current_primary = addressable.addresses.primary.active.first
    if current_primary
      current_primary.update!(active_until: Time.current)
    end
  end
end
