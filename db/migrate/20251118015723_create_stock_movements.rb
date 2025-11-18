class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :inventory_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :movement_type, null: false  # add, remove, set, adjust
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.decimal :previous_quantity, precision: 10, scale: 2, null: false
      t.decimal :new_quantity, precision: 10, scale: 2, null: false
      t.text :notes
      t.string :source  # web, line_bot, api

      t.timestamps
    end

    add_index :stock_movements, :movement_type
    add_index :stock_movements, :source
    add_index :stock_movements, :created_at
  end
end
