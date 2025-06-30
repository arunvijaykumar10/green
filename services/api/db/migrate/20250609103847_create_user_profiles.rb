class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone_no
      t.boolean :super_admin, default: false
      t.boolean :active, default: false
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :user_profiles, :email, unique: true
    add_index :user_profiles, :discarded_at

  end
end
