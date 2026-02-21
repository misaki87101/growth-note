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

ActiveRecord::Schema[7.2].define(version: 2026_02_21_130047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "feedback_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_id"], name: "index_comments_on_feedback_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
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
    t.index ["student_id"], name: "index_feedbacks_on_student_id"
    t.index ["teacher_id"], name: "index_feedbacks_on_teacher_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "feedback_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feedback_id"], name: "index_likes_on_feedback_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
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
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "check_items", "feedbacks"
  add_foreign_key "comments", "feedbacks"
  add_foreign_key "comments", "users"
  add_foreign_key "feedbacks", "users", column: "student_id"
  add_foreign_key "feedbacks", "users", column: "teacher_id"
  add_foreign_key "likes", "feedbacks"
  add_foreign_key "likes", "users"
  add_foreign_key "students", "users"
end
