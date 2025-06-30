class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.references :owned_by, null: false, foreign_key: true, foreign_key: { to_table: :user_profiles }
      t.references :approved_by, foreign_key: true, foreign_key: { to_table: :user_profiles }
      t.references :tenant, null: false, foreign_key: true, foreign_key: { to_table: :tenants }
      t.references :addresses, foreign_key: { to_table: :addresses }
      t.string :name
      t.string :code
      t.string :company_type
      t.string :fein
      t.string :phone
      t.string :nys_no
      t.string :signature_type, default: 'single'
      t.datetime :discarded_at
      t.datetime :approved_at
      t.boolean :approved, null: false, default: false
      t.boolean :suspended, null: false, default: false
      t.jsonb :audit_log, default: {}
      t.timestamps
    end
    add_index(:companies, :name, unique: true)
    add_index(:companies, :code, unique: true)
    add_index(:companies, :discarded_at)
  end
end
