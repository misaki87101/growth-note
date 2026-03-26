# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# 既存データを念のため全削除
GroupUser.delete_all
Group.delete_all
User.delete_all

# 1. グループ（クラス）作成
group_a = Group.create!(name: "○クラス")
group_b = Group.create!(name: "△クラス")
group_c = Group.create!(name: "⬜︎クラス")

# 2. 先生・生徒の作成
# パスワードは共通で "password" にしておく
teacher_a = User.create!(
  name: "A先生(全クラス担当)", 
  email: "teacher_a@example.com", 
  password: "password", 
  role: :teacher 
)

teacher_b = User.create!(
  name: "B先生(○クラス、△クラス担当)", 
  email: "teacher_b@example.com", 
  password: "password", 
  role: :teacher 
)

teacher_c = User.create!(
  name: "C先生(⬜︎クラス担当)", 
  email: "teacher_c@example.com", 
  password: "password", 
  role: :teacher 
)

student_a = User.create!(
  name: "生徒A(○クラス)", 
  email: "student_a@example.com", 
  password: "password", 
  role: :student
)

student_b = User.create!(
  name: "生徒B(△クラス)", 
  email: "student_b@example.com", 
  password: "password", 
  role: :student
)

student_c = User.create!(
  name: "生徒C(⬜︎クラス)", 
  email: "student_c@example.com", 
  password: "password", 
  role: :student
)

student_d = User.create!(
  name: "生徒D(○クラス)", 
  email: "student_d@example.com", 
  password: "password", 
  role: :student
)

student_e = User.create!(
  name: "生徒E(△クラス)", 
  email: "student_e@example.com", 
  password: "password", 
  role: :student
)

student_f = User.create!(
  name: "生徒F(⬜︎クラス)", 
  email: "student_f@example.com",
  password: "password",
  role: :student
)

# 3. 所属の紐付け
teacher_a.groups << [group_a, group_b, group_c] # A先生は全クラス
teacher_b.groups << [group_a, group_b]          # B先生は○クラスと△クラス
teacher_c.groups << group_c                    # C先生は⬜︎クラスのみ

student_a.groups << group_a                    # 生徒Aは○クラス
student_b.groups << group_b                    # 生徒Bは△クラス
student_c.groups << group_c                    # 生徒Cは⬜︎クラス
student_d.groups << group_a                    # 生徒Dは○クラス
student_e.groups << group_b                    # 生徒Eは△クラス
student_f.groups << group_c                    # 生徒Fは⬜︎クラス


puts "初期データの投入が完了しました！"