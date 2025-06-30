class CreateUserCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :user_credentials do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.string :subject
      t.datetime :first_login_at
      t.timestamps
    end
  end
end
