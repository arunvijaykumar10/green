class CompanyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    super_admin? || company_member?
  end

  def update?
    admin?
  end

  def create?
    admin?
  end

  def suspend?
    admin?
  end

  def activate?
    admin?
  end

  def submit_for_review?
    admin?
  end

  def approve?
    super_admin?
  end

  def reject?
    super_admin?
  end

  def show_configs?
    super_admin? || admin?
  end

  def review_status?
    super_admin? || admin?
  end

  private

  def super_admin?
    user&.super_admin?
  end

  def admin?
    company_member_with_role?('admin')
  end

  def employee?
    company_member_with_role?('employee')
  end

  def company_member?
    record.company_members.exists?(profile: user)
  end

  def company_member_with_role?(role_type)
    return false unless user && record
    
    record.company_members
          .joins(:access_role)
          .exists?(profile: user, access_roles: { role_type: role_type })
  end

  class Scope < Scope
    def resolve
      if user&.super_admin?
        scope.all
      else
        scope.joins(:company_members).where(company_members: { profile: user })
      end
    end
  end
end