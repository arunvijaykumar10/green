json.user do
  json.extract! @user, :id, :first_name, :last_name, :email, :phone_no, :created_at, :updated_at
  json.full_name @user.full_name
  json.super_admin @user.super_admin?
end

if @company.present?
  json.last_accessed_company do
    json.extract! @company, :id, :name, :code, :company_type, :approved
    json.last_accessed_at @last_company_access.updated_at
  end
end

if @role.present?
  json.role do
    json.extract! @role, :id, :name, :role_type, :category
    json.is_admin @role.role_type == 'admin'
  end
end