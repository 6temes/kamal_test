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

ActiveRecord::Schema[8.0].define(version: 2025_08_12_105559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solid_cache_dashboard_events", force: :cascade do |t|
    t.string "event_type", null: false
    t.bigint "key_hash", null: false
    t.string "key_string"
    t.integer "byte_size"
    t.float "duration"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_solid_cache_dashboard_events_on_created_at"
    t.index ["event_type"], name: "index_solid_cache_dashboard_events_on_event_type"
    t.index ["key_hash"], name: "index_solid_cache_dashboard_events_on_key_hash"
  end
end
