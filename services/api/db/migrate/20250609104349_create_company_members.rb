class CreateCompanyMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :company_members do |t|
      t.references :profile, null: false, foreign_key: { to_table: :user_profiles }
      t.references :company, null: false, foreign_key: { to_table: :companies }, index: true
      t.references :access_role, foreign_key: { to_table: :access_roles }, index: true
      t.datetime :invited_at, null: false
      t.datetime :joined_at, null: true
      t.datetime :discarded_at
      t.timestamps
    end
    add_index(:company_members, [ :profile_id, :company_id, :access_role_id ], unique: true)
  end
end
