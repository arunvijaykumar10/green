class CreateTenants < ActiveRecord::Migration[8.0]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.datetime :discarded_at
      t.timestamps
    end
    add_index(:tenants, :name, unique: true)
    add_index(:tenants, :code, unique: true)
    add_index(:tenants, :discarded_at)
  end
end