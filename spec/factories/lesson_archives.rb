# frozen_string_literal: true

FactoryBot.define do
  factory :lesson_archive do
    teacher { nil }
    group { nil }
    lesson_date { "2026-05-07" }
    title { "MyString" }
    schedule { "MyText" }
    items { "MyText" }
    notice { "MyText" }
  end
end
