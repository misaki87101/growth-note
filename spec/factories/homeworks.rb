# frozen_string_literal: true

FactoryBot.define do
  factory :homework do
    user { nil }
    feedback { nil }
    lesson_date { "2026-03-17" }
    content { "MyText" }
    hour { 1 }
    minute { 1 }
  end
end
