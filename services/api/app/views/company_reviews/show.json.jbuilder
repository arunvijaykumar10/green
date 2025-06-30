json.status "success"
json.message "Company review retrieved successfully"

json.data do
  json.company_review do
    json.extract! @company_review, :id, :status, :submitted_at, :reviewed_at, :review_notes
    json.company do
      json.extract! @company_review.company, :id, :name, :code, :company_type, :fein, :nys_no, :phone
    end
    if @company_review.reviewed_by
      json.reviewed_by do
        json.extract! @company_review.reviewed_by, :id, :first_name, :last_name, :email
      end
    end
  end
end