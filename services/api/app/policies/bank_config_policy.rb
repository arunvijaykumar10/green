class BankConfigPolicy < ApplicationPolicy
  def index?
    super_admin? || admin?
  end

  def show?
    super_admin? || admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  private

  def super_admin?
    user&.super_admin?
  end

  def admin?
    company_member_with_role?("admin")
  end

  def company_member?
    company = record&.company || Current.company
    return false unless user && company

    company.company_members.exists?(profile: user)
  end

  def company_member_with_role?(role_type)
    company = record.is_a?(Class) ? Current.company : (record&.company || Current.company)
    return false unless user && company

    company.company_members
           .joins(:access_role)
           .exists?(profile: user, access_roles: { role_type: role_type })
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
