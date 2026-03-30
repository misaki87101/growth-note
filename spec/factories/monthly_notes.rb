# frozen_string_literal: true

FactoryBot.define do
  factory :monthly_note do
    month { "2026-03-30" }
    group { nil }
    memo { "MyText" }
  end
end
