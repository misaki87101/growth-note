# frozen_string_literal: true

# spec/factories/homeworks.rb
FactoryBot.define do
  factory :homework do
    lesson_date { Time.zone.today }
    content { "今日の練習内容です" }
    hour { 1 }
    minute { 30 }
    association :user # 投稿者（生徒）

    # 画像を添付するテスト用（Active Storage）
    trait :with_image do
      after(:build) do |homework|
        homework.images.attach(
          io: Rails.root.join('spec/fixtures/files/test_image.png').open,
          filename: 'test_image.png',
          content_type: 'image/png'
        )
      end
    end
  end
end
