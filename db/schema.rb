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

ActiveRecord::Schema.define(version: 20141209045712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: true do |t|
    t.string   "company_number"
    t.string   "company_name"
    t.string   "company_type"
    t.string   "member_full_name"
    t.string   "member_first_name"
    t.string   "member_last_name"
    t.string   "member_title"
    t.string   "member_is_admin"
    t.string   "member_phone"
    t.string   "member_number"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "phone"
    t.string   "email"
    t.string   "website"
    t.string   "regions"
    t.string   "industries"
    t.string   "about"
    t.text     "locations"
    t.integer  "page"
    t.string   "url"
    t.text     "html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "my_processes", force: true do |t|
    t.integer  "pid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
