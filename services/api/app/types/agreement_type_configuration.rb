require "dry-types"

module AgreementTypeConfiguration
  module Types
    include Dry.Types()
  end

  # Common configuration attributes for AEA (Actors' Equity Association)
  AEACommonConfig = Types::Hash.schema(
    aea_employer_id: Types::String,
    aea_production_title: Types::String,
    aea_business_representative: Types::Coercible::String,
  ).with_key_transform(&:to_sym)

  # A more general configuration that includes AEA details plus production type
  CommonProductionConfig = Types::Hash.schema(
    musical_or_dramatic: Types::String,
    aea_employer_id: Types::String,
    aea_production_title: Types::String,
    aea_business_representative: Types::Coercible::String,
  ).with_key_transform(&:to_sym)

  # Specific agreement configurations
  # These two inherit all fields from CommonProductionConfig
  EquityOrLeagueProductionContractConfig = CommonProductionConfig
  OffBroadwayAgreementConfig = CommonProductionConfig

  DevelopmentAgreementConfig = Types::Hash.schema(
    tier: Types::String,
    aea_employer_id: Types::String,
    aea_production_title: Types::String,
    aea_business_representative: Types::Coercible::String,
  ).with_key_transform(&:to_sym)
end
