json.status "success"
json.message "Logged in successfully"

json.data do
  json.redirect_to @redirect_path
end