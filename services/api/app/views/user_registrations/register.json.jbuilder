json.status "success"
json.message "Registration completed successfully"

json.data do
  json.user do
    json.id @user_profile.id
    json.email @user_profile.email
    json.full_name @user_profile.full_name
    json.credential do
      json.subject @user_credential.subject
      json.first_login_at @user_credential.first_login_at
    end
  end

  json.company do
    json.id @company.id
    json.name @company.name
    json.code @company.code
  end

  json.company_member do
    json.id @company_member.id
    json.access_role do
      json.id @company_member.access_role&.id
      json.name @company_member.access_role&.name
      json.role_type @company_member.access_role&.role_type
    end
  end

  json.tenant do
    json.id @tenant.id
    json.name @tenant.name
    json.code @tenant.code
  end
end
