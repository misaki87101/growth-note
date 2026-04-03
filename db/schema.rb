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

ActiveRecord::Schema[7.2].define(version: 2026_04_03_031717) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "board_comments", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "board_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_board_comments_on_board_id"
    t.index ["user_id"], name: "index_board_comments_on_user_id"
  end

  create_table "board_likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "board_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_board_likes_on_board_id"
    t.index ["user_id"], name: "index_board_likes_on_user_id"
  end

  create_table "boards", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category"
    t.integer "group_id"
    t.index ["user_id"], name: "index_boards_on_user_id"
  end

  create_table "check_items", force: :cascade do |t|
    t.bigint "feedback_id", null: false
    t.string "name"
    t.string "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timestamp"
    t.index ["feedback_id"], name: "index_check_items_on_feedback_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "feedback_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "homework_id"
    t.index ["feedback_id"], name: "index_comments_on_feedback_id"
    t.index ["homework_id"], name: "index_comments_on_homework_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "daily_reports", force: :cascade do |t|
    t.integer "group_id"
    t.date "date"
    t.integer "staff_count"
    t.integer "new_customers"
    t.integer "repeat_customers"
    t.string "referral_source"
    t.integer "tech_sales"
    t.integer "item_sales"
    t.integer "tech_target"
    t.integer "item_target"
    t.float "total_working_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "referral_data"
    t.text "memo"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "teacher_id", null: false
    t.date "lesson_date"
    t.integer "evaluation"
    t.text "lesson_content"
    t.text "issue"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rating"
    t.string "title"
    t.integer "duration"
    t.integer "hour"
    t.integer "minute"
    t.integer "group_id"
    t.index ["student_id"], name: "index_feedbacks_on_student_id"
    t.index ["teacher_id"], name: "index_feedbacks_on_teacher_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted", default: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_code"
  end

  create_table "homeworks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "feedback_id"
    t.date "lesson_date"
    t.text "content"
    t.integer "hour"
    t.integer "minute"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_id"], name: "index_homeworks_on_feedback_id"
    t.index ["user_id"], name: "index_homeworks_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "feedback_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "homework_id"
    t.index ["feedback_id"], name: "index_likes_on_feedback_id"
    t.index ["homework_id"], name: "index_likes_on_homework_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "monthly_notes", force: :cascade do |t|
    t.date "month"
    t.bigint "group_id", null: false
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_monthly_notes_on_group_id"
  end

  create_table "staff_sales", force: :cascade do |t|
    t.bigint "daily_report_id", null: false
    t.bigint "user_id", null: false
    t.integer "tech_sales"
    t.integer "item_sales"
    t.float "working_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tech_target"
    t.integer "item_target"
    t.string "start_time"
    t.string "end_time"
    t.integer "break_time"
    t.index ["daily_report_id"], name: "index_staff_sales_on_daily_report_id"
    t.index ["user_id"], name: "index_staff_sales_on_user_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "background"
    t.text "feature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bio"
    t.text "goals"
    t.text "features"
    t.text "favorite_things"
    t.text "message"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.date "birthday"
    t.bigint "group_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["group_id"], name: "index_users_on_group_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "board_comments", "boards"
  add_foreign_key "board_comments", "users"
  add_foreign_key "board_likes", "boards"
  add_foreign_key "board_likes", "users"
  add_foreign_key "boards", "users"
  add_foreign_key "check_items", "feedbacks"
  add_foreign_key "comments", "feedbacks"
  add_foreign_key "comments", "homeworks"
  add_foreign_key "comments", "users"
  add_foreign_key "feedbacks", "users", column: "student_id"
  add_foreign_key "feedbacks", "users", column: "teacher_id"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "homeworks", "feedbacks"
  add_foreign_key "homeworks", "users"
  add_foreign_key "likes", "feedbacks"
  add_foreign_key "likes", "homeworks"
  add_foreign_key "likes", "users"
  add_foreign_key "monthly_notes", "groups"
  add_foreign_key "staff_sales", "daily_reports"
  add_foreign_key "staff_sales", "users"
  add_foreign_key "students", "users"
  add_foreign_key "users", "groups"
end
