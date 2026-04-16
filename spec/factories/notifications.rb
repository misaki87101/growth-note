# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    recipient_id { 1 }
    actor_id { 1 }
    action { "MyString" }
    notifiable_id { 1 }
    notifiable_type { "MyString" }
    read_at { "2026-04-16 02:17:35" }
  end
end
