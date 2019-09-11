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

ActiveRecord::Schema.define(version: 201901241536541) do

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zizia_csv_import_details", force: :cascade do |t|
    t.integer "csv_import_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["csv_import_id"], name: "index_zizia_csv_import_details_on_csv_import_id"
  end

  create_table "zizia_csv_imports", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "manifest"
    t.string "fedora_collection_id"
    t.index ["user_id"], name: "index_zizia_csv_imports_on_user_id"
  end

  create_table "zizia_pre_ingest_files", force: :cascade do |t|
    t.integer "size"
    t.text "row"
    t.integer "row_number"
    t.string "filename"
    t.integer "pre_ingest_work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pre_ingest_work_id"], name: "index_zizia_pre_ingest_files_on_pre_ingest_work_id"
  end

  create_table "zizia_pre_ingest_works", force: :cascade do |t|
    t.integer "parent_object"
    t.integer "csv_import_detail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["csv_import_detail_id"], name: "index_zizia_pre_ingest_works_on_csv_import_detail_id"
  end

end
