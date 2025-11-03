class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items do |t|
      t.references :family, null: false, foreign_key: true
      t.string :brand
      t.string :name
      t.string :category
      t.decimal :quantity
      t.string :unit
      t.text :notes

      t.timestamps
    end
  end
end
