# frozen_string_literal: true

FactoryBot.define do
  factory :board_comment do
    content { "MyText" }
    user { nil }
    board { nil }
  end
end
