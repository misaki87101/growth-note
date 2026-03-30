# frozen_string_literal: true

class DailyReport < ApplicationRecord
  belongs_to :group
  has_many :staff_sales, dependent: :destroy
  accepts_nested_attributes_for :staff_sales, allow_destroy: true

  store_accessor :referral_data

  # 来店動機の選択肢を定義
  REFERRAL_SOURCES = %w[
    HPB Instagram ミニモ ネイリー Google 紹介 その他
  ].freeze

  # 親（日報）と一緒に子（スタッフ売上）を保存・更新できるようにする魔法
  accepts_nested_attributes_for :staff_sales, allow_destroy: true

  # 目標を取得するメソッド（入力がない場合はその月の最新目標を拾う）
  def current_tech_target
    return tech_target if tech_target.present?

    # 同じグループ、同じ月で、目標が入力されている最新のレコードを探す
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

    # その月のこれまでの累計を取得して、目標から引く
    monthly_total = group.daily_reports.where(date: date.all_month).sum(:tech_sales)
    [target - monthly_total, 0].max
  end

  # 達成率をこの新しいメソッドを使って計算し直す
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

  # 目標達成率（技術売上ベース）の計算
  def tech_achievement_rate
    return 0 if tech_target.to_i.zero?

    (tech_sales.to_f / tech_target * 100).round(1)
  end

  # 生産性（1時間あたりの売上）
  def productivity
    return 0 if total_working_hours.to_f.zero?

    (total_sales / total_working_hours).round(0)
  end
end
