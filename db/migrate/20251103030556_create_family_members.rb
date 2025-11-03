class CreateFamilyMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :family_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :family, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
