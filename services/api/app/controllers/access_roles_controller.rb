class AccessRolesController < ApplicationController
  skip_before_action :authenticate_user, only: [:admin_roles, :employee_roles]
  skip_before_action :set_company_context, only: [:admin_roles, :employee_roles]
  skip_after_action :verify_authorized, only: [:admin_roles, :employee_roles]
  skip_after_action :verify_policy_scoped, only: [:admin_roles, :employee_roles]

  def index
    @access_roles = policy_scope(AccessRole)
    render :index
  end

  def show
    @access_role = AccessRole.find(params[:id])
    authorize @access_role
    render :show
  rescue ActiveRecord::RecordNotFound
    @errors = ["Access role not found"]
    render :error, status: :not_found
  end

  def admin_roles
    @admin_roles = AccessRole.where(role_type: 'admin')
    render :admin_roles
  end

  def employee_roles
    @union_roles = AccessRole.where(role_type: 'employee', category: 'union')
    @non_union_roles = AccessRole.where(role_type: 'employee', category: 'non-union')
    render :employee_roles
  end
end