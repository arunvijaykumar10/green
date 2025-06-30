class CompanyReviewPolicy < ApplicationPolicy
  def index?
    user&.super_admin?
  end

  def show?
    user&.super_admin?
  end

  def update?
    user&.super_admin?
  end

  def approve?
    user&.super_admin?
  end

  def reject?
    user&.super_admin?
  end

  class Scope < Scope
    def resolve
      if user&.super_admin?
        scope.all
      else
        scope.none
      end
    end
  end
end