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

ActiveRecord::Schema.define(version: 20151019104535) do

  create_table "code_maps", force: :cascade do |t|
    t.integer "mapping_profile_id"
    t.integer "code"
    t.string  "animation"
  end

  add_index "code_maps", ["mapping_profile_id"], name: "index_code_maps_on_mapping_profile_id"

  create_table "devices", force: :cascade do |t|
    t.integer "user_id"
    t.string  "name"
    t.string  "given_id"
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id"

  create_table "mapping_profiles", force: :cascade do |t|
    t.integer "device_id"
    t.string  "name"
  end

  add_index "mapping_profiles", ["device_id"], name: "index_mapping_profiles_on_device_id"

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_hash"
    t.string "auth_token"
  end

end
