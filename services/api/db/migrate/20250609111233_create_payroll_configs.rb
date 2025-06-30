class CreatePayrollConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :payroll_configs do |t|
      t.references :company, null: false, foreign_key: { to_table: :companies }, index: true
      t.string :frequency
      t.string :period
      t.date :start_date
      t.integer :check_start_number
      t.boolean :active, default: true
      t.boolean :approved, null: false, default: false
      t.timestamps
    end
  end
end
