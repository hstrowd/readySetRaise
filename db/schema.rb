# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150215173400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "cleanup_time"
    t.integer  "fundraiser_id", null: false
    t.integer  "creator_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["fundraiser_id"], name: "index_events_on_fundraiser_id", using: :btree

  create_table "fundraisers", force: true do |t|
    t.string   "title",             null: false
    t.string   "description"
    t.datetime "pledge_start_time", null: false
    t.datetime "pledge_end_time",   null: false
    t.integer  "organization_id",   null: false
    t.integer  "creator_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fundraisers", ["organization_id"], name: "index_fundraisers_on_organization_id", using: :btree

  create_table "organization_memberships", id: false, force: true do |t|
    t.integer "organization_id", null: false
    t.integer "member_id",       null: false
  end

  create_table "organizations", force: true do |t|
    t.string   "name",                         null: false
    t.string   "url_key",                      null: false
    t.text     "description",                  null: false
    t.string   "homepage_url",                 null: false
    t.boolean  "is_verified",  default: false, null: false
    t.string   "donation_url"
    t.integer  "creator_id",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_url"
  end

  add_index "organizations", ["creator_id"], name: "index_organizations_on_creator_id", using: :btree
  add_index "organizations", ["url_key"], name: "index_organizations_on_url_key", unique: true, using: :btree

  create_table "pledges", force: true do |t|
    t.integer  "donor_id"
    t.integer  "team_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pledges", ["donor_id"], name: "index_pledges_on_donor_id", using: :btree
  add_index "pledges", ["team_id"], name: "index_pledges_on_team_id", using: :btree

  create_table "team_members", id: false, force: true do |t|
    t.integer "team_id", null: false
    t.integer "user_id", null: false
  end

  create_table "teams", force: true do |t|
    t.string   "name"
    t.float    "pledge_target"
    t.integer  "event_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["event_id"], name: "index_teams_on_event_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
