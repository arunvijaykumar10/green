class CompanyUnionConfiguration < ApplicationRecord
  belongs_to :company
  validates :union_type, presence: true, inclusion: { in: %w[union non-union] }
  validates :union_name, presence: true, if: -> { union_type == "union" }
  validates :agreement_type, presence: true, inclusion: { in: %w[equity_or_league_production_contract off_broadway_agreement development_agreement 29_hour_reading] }, if: -> { union_type == "union" }
  validates :agreement_type_configuration, presence: true, if: -> { union_type == "union" && %w[equity_or_league_production_contract off_broadway_agreement development_agreement].include?(agreement_type) }
  validate :validate_agreement_configuration, if: -> { union_type == "union" }
  before_validation :clear_union_fields_if_non_union
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_agreement_type, ->(type) { where(agreement_type: type) }
  scope :approved, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false) }

  def agreement_type_configuration=(value)
    @raw_config = value
    super(value)
  end

  private

  def clear_union_fields_if_non_union
    if union_type == "non-union"
      self.union_name = nil
      self.agreement_type = nil
      self.agreement_type_configuration = nil
    end
  end

  def validate_agreement_configuration
    return unless @raw_config && agreement_type

    begin
      case agreement_type
      when "equity_or_league_production_contract"
        AgreementTypeConfiguration::EquityOrLeagueProductionContractConfig[@raw_config.with_indifferent_access]
      when "off_broadway_agreement"
        AgreementTypeConfiguration::OffBroadwayAgreementConfig[@raw_config.with_indifferent_access]
      when "development_agreement"
        AgreementTypeConfiguration::DevelopmentAgreementConfig[@raw_config.with_indifferent_access]
      end
    rescue Dry::Types::SchemaError => e
      errors.add(:agreement_type_configuration, "invalid configuration: #{e.message}")
    rescue Dry::Types::ConstraintError => e
      errors.add(:agreement_type_configuration, "constraint violation: #{e.message}")
    end
  end
end