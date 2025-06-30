
class CreateCompanyOnboardings < ActiveRecord::Migration[8.0]
  def change
    create_table :company_onboardings do |t|
      t.references :company, null: false, foreign_key: true
      t.string :status, null: false, default: 'company_details'
      t.jsonb :metadata, default: {}
      t.boolean :approved, default: false
      t.timestamps
    end
  end
end
