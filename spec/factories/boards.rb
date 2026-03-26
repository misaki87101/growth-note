# frozen_string_literal: true

FactoryBot.define do
  factory :board do
    title { "MyString" }
    content { "MyText" }
    user { nil }
  end
end
