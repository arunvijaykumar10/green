json.status "error"
json.message "Operation failed"

json.errors @errors if defined?(@errors) && @errors.present?