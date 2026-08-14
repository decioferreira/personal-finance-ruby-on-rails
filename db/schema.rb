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

ActiveRecord::Schema[8.1].define(version: 2026_08_14_220036) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index "user_id, LOWER(name)", name: "index_categories_on_user_id_and_lower_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "monthly_incomes", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "month", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "month"], name: "index_monthly_incomes_on_user_id_and_month", unique: true
    t.index ["user_id"], name: "index_monthly_incomes_on_user_id"
    t.check_constraint "amount >= 0", name: "monthly_incomes_amount_non_negative"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "spending_entries", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "description", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category_id"], name: "index_spending_entries_on_category_id"
    t.index ["user_id", "date"], name: "index_spending_entries_on_user_id_and_date"
    t.index ["user_id"], name: "index_spending_entries_on_user_id"
    t.check_constraint "amount > 0", name: "spending_entries_amount_positive"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "categories", "users"
  add_foreign_key "monthly_incomes", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "spending_entries", "categories", on_delete: :restrict
  add_foreign_key "spending_entries", "users"
end
