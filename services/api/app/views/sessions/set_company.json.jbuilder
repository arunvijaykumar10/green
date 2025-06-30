json.status "success"
json.message "Switched to #{@company.name}"

json.data do
  json.redirect_to @redirect_path
end