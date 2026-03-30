# frozen_string_literal: true

FactoryBot.define do
  factory :daily_report do
    group_id { 1 }
    date { "2026-03-30" }
    staff_count { 1 }
    new_customers { 1 }
    repeat_customers { 1 }
    referral_source { "MyString" }
    tech_sales { 1 }
    item_sales { 1 }
    tech_target { 1 }
    item_target { 1 }
    total_working_hours { 1.5 }
  end
end
