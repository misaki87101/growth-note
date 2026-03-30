# frozen_string_literal: true

FactoryBot.define do
  factory :staff_sale do
    daily_report { nil }
    user { nil }
    tech_sales { 1 }
    item_sales { 1 }
    working_hours { 1.5 }
  end
end
