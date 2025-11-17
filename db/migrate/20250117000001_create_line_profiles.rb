class CreateLineProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :line_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :line_user_id, null: false
      t.string :display_name
      t.string :picture_url
      t.text :status_message
      t.string :bind_token
      t.datetime :bind_token_expires_at

      t.timestamps
    end

    add_index :line_profiles, :line_user_id, unique: true
    add_index :line_profiles, :bind_token, unique: true
  end
end
