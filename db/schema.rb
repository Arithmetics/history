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

ActiveRecord::Schema.define(version: 2020_06_18_024104) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fantasy_games", force: :cascade do |t|
    t.integer "year"
    t.integer "week"
    t.bigint "away_fantasy_team_id"
    t.bigint "home_fantasy_team_id"
    t.float "away_score"
    t.float "home_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["away_fantasy_team_id"], name: "index_fantasy_games_on_away_fantasy_team_id"
    t.index ["home_fantasy_team_id"], name: "index_fantasy_games_on_home_fantasy_team_id"
  end

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
    t.string "picture_id"
    t.string "nfl_URL_name"
  end

  create_table "playoff_odds", force: :cascade do |t|
    t.integer "week"
    t.string "type"
    t.float "odds"
    t.bigint "fantasy_team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["fantasy_team_id"], name: "index_playoff_odds_on_fantasy_team_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.string "position"
    t.integer "year"
    t.bigint "fantasy_team_id", null: false
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "price"
    t.index ["fantasy_team_id"], name: "index_purchases_on_fantasy_team_id"
    t.index ["player_id"], name: "index_purchases_on_player_id"
  end

  create_table "scheduled_fantasy_games", force: :cascade do |t|
    t.integer "week"
    t.bigint "away_fantasy_team_id"
    t.bigint "home_fantasy_team_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["away_fantasy_team_id"], name: "index_scheduled_fantasy_games_on_away_fantasy_team_id"
    t.index ["home_fantasy_team_id"], name: "index_scheduled_fantasy_games_on_home_fantasy_team_id"
  end

  create_table "season_stats", force: :cascade do |t|
    t.integer "year"
    t.integer "games_played"
    t.integer "passing_completions"
    t.integer "passing_attempts"
    t.integer "passing_yards"
    t.integer "passing_touchdowns"
    t.integer "interceptions"
    t.integer "rushing_attempts"
    t.integer "rushing_yards"
    t.integer "rushing_touchdowns"
    t.integer "receiving_yards"
    t.integer "receptions"
    t.integer "receiving_touchdowns"
    t.integer "fumbles_lost"
    t.float "age_at_season"
    t.integer "experience_at_season"
    t.bigint "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "position"
    t.integer "rank_reg"
    t.integer "rank_ppr"
    t.float "fantasy_points_reg"
    t.float "fantasy_points_ppr"
    t.index ["player_id"], name: "index_season_stats_on_player_id"
  end

  add_foreign_key "fantasy_games", "fantasy_teams", column: "away_fantasy_team_id"
  add_foreign_key "fantasy_games", "fantasy_teams", column: "home_fantasy_team_id"
  add_foreign_key "fantasy_starts", "fantasy_teams"
  add_foreign_key "fantasy_starts", "players"
  add_foreign_key "fantasy_teams", "owners"
  add_foreign_key "playoff_odds", "fantasy_teams"
  add_foreign_key "purchases", "fantasy_teams"
  add_foreign_key "purchases", "players"
  add_foreign_key "scheduled_fantasy_games", "fantasy_teams", column: "away_fantasy_team_id"
  add_foreign_key "scheduled_fantasy_games", "fantasy_teams", column: "home_fantasy_team_id"
  add_foreign_key "season_stats", "players"
end
