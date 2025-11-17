# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_03_030604) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_families_on_creator_id"
  end

  create_table "family_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "family_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_members_on_family_id"
    t.index ["user_id"], name: "index_family_members_on_user_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "brand"
    t.string "name"
    t.string "category"
    t.decimal "quantity"
    t.string "unit"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_inventory_items_on_family_id"
  end

  create_table "line_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "line_user_id", null: false
    t.string "display_name"
    t.string "picture_url"
    t.text "status_message"
    t.string "bind_token"
    t.datetime "bind_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bind_token"], name: "index_line_profiles_on_bind_token", unique: true
    t.index ["line_user_id"], name: "index_line_profiles_on_line_user_id", unique: true
    t.index ["user_id"], name: "index_line_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "families", "users", column: "creator_id"
  add_foreign_key "family_members", "families"
  add_foreign_key "family_members", "users"
  add_foreign_key "inventory_items", "families"
  add_foreign_key "line_profiles", "users"
end
