json.status "success"
json.message "Company review status retrieved successfully"

json.data do
  json.review_status do
    json.extract! @status, :status, :notes, :reviewed_at, :reviewed_by
  end
end