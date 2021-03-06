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

ActiveRecord::Schema.define(version: 2020_04_27_221156) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brackets", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "bracket_data"
    t.text "lookup_by_label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_brackets_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "games", id: :serial, force: :cascade do |t|
    t.integer "team_id"
    t.integer "bracket_id"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked", default: false
    t.index ["bracket_id"], name: "index_games_on_bracket_id"
    t.index ["team_id"], name: "index_games_on_team_id"
  end

  create_table "heckles", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "from_id"
    t.integer "to_id"
  end

  create_table "heckles_users", id: false, force: :cascade do |t|
    t.bigint "heckle_id", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "heckle_id"], name: "index_heckles_users_on_user_id_and_heckle_id", unique: true
  end

  create_table "scenarios", force: :cascade do |t|
    t.string "scenario_teams"
    t.string "result"
    t.integer "remaining_games"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "seed"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "name_locked", default: false
    t.boolean "eliminated", default: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password"
    t.string "password_digest"
    t.string "role"
    t.string "remember_token"
    t.string "email"
    t.integer "current_score", default: 0
    t.boolean "bracket_locked", default: false
    t.string "chat_name"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

end
