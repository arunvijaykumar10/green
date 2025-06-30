class CreateCompanyAccessLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :company_access_logs do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :action_type, null: false, default: "view_dashboard"
      t.timestamps
    end

    # Add indexes for efficient querying, especially when looking up by user, company, or time.
    add_index :company_access_logs, [ :user_profile_id, :company_id, :created_at ], name: "idx_user_company_access_log_composite"
    add_index :company_access_logs, :created_at, order: { created_at: :desc } # For finding latest global access
  end
end
