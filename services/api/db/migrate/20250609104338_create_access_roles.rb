class CreateAccessRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :access_roles do |t|
      t.string :name
      t.string :category #[union, non-union]
      t.string :role_type #[admin,(union, non-union)employee]
      t.timestamps
    end
  end
end
