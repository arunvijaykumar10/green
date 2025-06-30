class CreateCompanyUnionConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :company_union_configurations do |t|
      t.references :company, null: false, foreign_key: { to_table: :companies }, index: true
      t.string :union_type, null: false, default: 'non-union'
      t.string :union_name
      t.string :agreement_type
      t.jsonb :agreement_type_configuration, default: {}
      t.boolean :active, default: true
      t.boolean :approved, null: false, default: false
      t.timestamps
    end

    add_index :company_union_configurations, :agreement_type
  end
end
