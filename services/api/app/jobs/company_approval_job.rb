class CompanyApprovalJob < ApplicationJob
  queue_as :default

  def perform(company_review)
    company = company_review.company

    ActiveRecord::Base.transaction do
      # Approve company
      company.update!(approved: true)

      # Approve related records if they exist
      company.bank_config&.update!(approved: true)
      company.payroll_config&.update!(approved: true)
      company.company_union_configuration&.update!(approved: true)
    end
  end
end