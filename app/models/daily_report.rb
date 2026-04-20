# frozen_string_literal: true

class DailyReport < ApplicationRecord
  belongs_to :group
  has_many :staff_sales, dependent: :destroy

  # 💡 7行目と15行目で重複していたので1つにまとめました
  accepts_nested_attributes_for :staff_sales, allow_destroy: true

  store_accessor :referral_data

  REFERRAL_SOURCES = %w[
    HPB Instagram ミニモ ネイリー Google 紹介 その他
  ].freeze

  # 目標を取得するメソッド
  def current_tech_target
    return tech_target if tech_target.present?

    group.daily_reports
         .where(date: date.beginning_of_month..date)
         .where.not(tech_target: nil)
         .order(date: :desc)
         .first&.tech_target || 0
  end

  # 目標まであといくらか
  def remaining_tech_sales
    target = current_tech_target
    return 0 if target.zero?

    monthly_total = group.daily_reports.where(date: date.all_month).sum(:tech_sales)
    [target - monthly_total, 0].max
  end

  # 達成率（41行目にあった「賢い方」を採用）
  def tech_achievement_rate
    target = current_tech_target
    return 0 if target.zero?

    (tech_sales.to_f / target * 100).round(1)
  end

  # 総売上の計算
  def total_sales
    (tech_sales || 0) + (item_sales || 0)
  end

  # 客数合計の計算
  def total_customers
    (new_customers || 0) + (repeat_customers || 0)
  end

  # 生産性
  def productivity
    return 0 if total_working_hours.to_f.zero?

    (total_sales / total_working_hours.to_f).round(0)
  end
end
