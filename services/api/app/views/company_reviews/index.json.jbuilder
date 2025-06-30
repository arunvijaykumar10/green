json.status "success"
json.message "Company reviews retrieved successfully"

json.data do
  json.company_reviews @company_reviews do |review|
    json.extract! review, :id, :status, :submitted_at, :reviewed_at, :review_notes
    json.company do
      json.extract! review.company, :id, :name, :code, :company_type
    end
    if review.reviewed_by
      json.reviewed_by do
        json.extract! review.reviewed_by, :id, :first_name, :last_name, :email
      end
    end
  end
end