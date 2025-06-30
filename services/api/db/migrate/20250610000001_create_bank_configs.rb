class CreateBankConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_configs do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.string :bank_name, null: false
      t.string :account_number, null: false
      t.string :routing_number_ach, null: false
      t.string :routing_number_wire, null: false
      t.string :account_type, null: false
      t.boolean :authorized, null: false
      t.boolean :active, default: true
      t.boolean :approved, null: false, default: false
      t.timestamps
    end

    add_index :bank_configs, [:company_id, :active], unique: true, where: "active = true"
  end
end
