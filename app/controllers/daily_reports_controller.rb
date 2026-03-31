# frozen_string_literal: true

class DailyReportsController < ApplicationController
  # 1. 掲示板等で使っている「自作のログインチェックメソッド」に書き換える
  before_action :logged_in_user

  def index
    # 2. 中間テーブル経由で「所属している最初のグループ」を取得する
    # (もし複数グループに対応させるなら where(group_id: current_user.group_ids) にします)
    @display_month = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month
    group = current_user.groups.first

    @daily_reports = if group
                       DailyReport.where(group_id: group.id)
                                  .where(date: @display_month..@display_month.end_of_month)
                                  .order(date: :desc)
                     else
                       []
                     end
  end

  def new
    @daily_report = DailyReport.new
    @daily_report.date = Time.zone.today
    group = current_user.groups.first

    return unless group

    @nailists = group.users.where(role: :student)
    # 1. 最後に「スタッフ別目標」が入力された日報を特定する
    last_report_with_staff_targets = group.daily_reports
                                          .joins(:staff_sales)
                                          .where.not(staff_sales: { tech_target: nil })
                                          .order(date: :desc)
                                          .first

    @nailists.each do |nailist|
      # 2. その日報から、該当スタッフの目標を探す
      prev_target = last_report_with_staff_targets&.staff_sales&.find_by(user_id: nailist.id)&.tech_target

      # 3. フォームを構築（値があればセット、なければ空にする）
      @daily_report.staff_sales.build(
        user_id: nailist.id,
        tech_target: prev_target # ここに前回の値が入る
      )
    end
  end

  def edit
    @daily_report = DailyReport.find(params[:id])
    group = current_user.groups.first

    # 【重要】もしスタッフ入力欄が空（過去に保存されていなかった）の場合のケア
    return unless group

    @nailists = group.users.where(role: User.roles[:student])
    @nailists.each do |nailist|
      # 既にデータがあるか確認し、なければ空の入力欄を作る
      @daily_report.staff_sales.build(user_id: nailist.id) unless @daily_report.staff_sales.exists?(user_id: nailist.id)
    end
  end

  def create
    @daily_report = DailyReport.new(daily_report_params)
    @daily_report.group = current_user.groups.first

    # 明示的に来店動機をセット
    @daily_report.referral_data = params[:daily_report][:referral_data] if params[:daily_report][:referral_data]

    if @daily_report.save
      redirect_to daily_reports_path, notice: "保存しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @daily_report = DailyReport.find(params[:id])

    if @daily_report.update(daily_report_params)
      redirect_to daily_reports_path, notice: "日報を更新しました！"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @daily_report = DailyReport.find(params[:id])
    @daily_report.destroy
    redirect_to daily_reports_path, notice: "日報を削除しました。"
  end

  def analysis
    # --- 今月のデータ取得 ---
    @display_month = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month
    range = @display_month..@display_month.end_of_month
    group = current_user.groups.first
    @reports = group.daily_reports.where(date: range)

    @monthly_note = group.monthly_notes.find_or_initialize_by(month: @display_month)

    # --- 来店動機の集計ロジック ---
    @referral_summary = Hash.new(0)
    @reports.each do |report|
      # referral_dataが入っている場合のみ処理
      next if report.referral_data.blank?

      report.referral_data.each do |source, count|
        # sourceは"HPB"など、countは"2"などの文字列なので数値に変換して加算
        @referral_summary[source] += count.to_i
      end
    end
    # ----------------------------------------------

    # --- 1年前のデータを取得 ---
    last_year_range = (@display_month - 1.year)..(@display_month - 1.year).end_of_month
    @last_year_reports = group.daily_reports.where(date: last_year_range)

    # スタッフ別集計
    @staff_summary = StaffSale.where(daily_report_id: @reports.pluck(:id))
                              .group(:user_id)
                              .select("user_id,
                                     SUM(tech_sales) as total_tech,
                                     SUM(item_sales) as total_item,
                                     SUM(working_hours) as total_hours,
                                     MAX(tech_target) as tech_target")
  end

  private

  def daily_report_params
    params.require(:daily_report).permit(
      :date, :tech_sales, :item_sales, :new_customers, :repeat_customers,
      :staff_count, :total_working_hours, :tech_target, :item_target, :memo, # ←このコンマが大事！
      :referral_data,
      staff_sales_attributes: %i[id user_id tech_target tech_sales item_sales working_hours _destroy]
    )
  end
end
