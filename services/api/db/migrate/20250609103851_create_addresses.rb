class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :address_type, null: false
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false
      t.string :country, null: false, default: "US"
      t.datetime :active_from, null: false
      t.datetime :active_until
      t.references :addressable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
