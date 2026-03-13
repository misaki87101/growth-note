# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email } # 👈 free_email から email に変更
    password { 'password' }
    password_confirmation { 'password' }
  end
end
