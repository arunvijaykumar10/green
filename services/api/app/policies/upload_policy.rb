# app/policies/upload_policy.rb
class UploadPolicy < ApplicationPolicy
  # The 'record' for this policy would be the symbol ':upload'.
  # So you would access `record` in the policy to be `:upload`.

  def new?
    # Only allow company members (any role) or super admins to generate upload URLs
    admin?
  end

  def admin?
    return false unless user && Current.company

    Current.company.company_members
                   .joins(:access_role)
                   .exists?(profile: user, access_roles: { role_type: 'admin' })
  end

  class Scope < Scope
    def resolve
      scope.joins(:company_members).where(company_members: { profile: user })
    end
  end
end
