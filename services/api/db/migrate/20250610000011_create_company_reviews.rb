class CreateCompanyReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :company_reviews do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.string :status, null: false, default: "pending"
      t.text :review_notes
      t.references :reviewed_by, foreign_key: { to_table: :user_profiles }
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.timestamps
    end
  end
end