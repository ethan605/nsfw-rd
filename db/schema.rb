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

ActiveRecord::Schema.define(version: 20160323123535) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "content_compare_records", force: :cascade do |t|
    t.integer  "compare_result"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "first_image_id",  null: false
    t.integer  "second_image_id", null: false
  end

  add_index "content_compare_records", ["first_image_id"], name: "index_content_compare_records_on_first_image_id", using: :btree
  add_index "content_compare_records", ["second_image_id"], name: "index_content_compare_records_on_second_image_id", using: :btree

  create_table "content_images", force: :cascade do |t|
    t.string   "image_url"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.decimal  "raw_average_score", default: 0.0
    t.decimal  "weighted_score",    default: 0.0
    t.integer  "profile_id",                      null: false
  end

  add_index "content_images", ["profile_id"], name: "index_content_images_on_profile_id", using: :btree

  create_table "content_profiles", force: :cascade do |t|
    t.string   "screen_name"
    t.decimal  "raw_average_score", default: 0.0
    t.decimal  "weighted_score",    default: 0.0
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

end
