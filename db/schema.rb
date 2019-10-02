# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_29_035240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fantasy_starts", force: :cascade do |t|
    t.float "points"
    t.bigint "fantasy_team_id", null: false
    t.bigint "player_id", null: false
    t.integer "year"
    t.integer "week"
    t.string "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fantasy_team_id"], name: "index_fantasy_starts_on_fantasy_team_id"
    t.index ["player_id"], name: "index_fantasy_starts_on_player_id"
  end

  create_table "fantasy_teams", force: :cascade do |t|
    t.string "name"
    t.integer "year"
    t.bigint "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["owner_id"], name: "index_fantasy_teams_on_owner_id"
  end

  create_table "owners", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_owners_on_name", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.date "birthdate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "fantasy_starts", "fantasy_teams"
  add_foreign_key "fantasy_starts", "players"
  add_foreign_key "fantasy_teams", "owners"
end
