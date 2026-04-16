# frozen_string_literal: true

# app/controllers/dashboards_controller.rb

class DashboardsController < ApplicationController
  before_action :logged_in_user

  def index
    show # indexが呼ばれたらshowを実行する
  end

  def show
    if current_user.teacher?
      # 1. 自分が所属するグループ（クラス）のIDをすべて取得
      my_group_ids = current_user.groups.ids

      # 2. そのグループに所属している生徒へのフィードバックだけに限定
      @feedbacks = Feedback.where(group_id: my_group_ids).order(lesson_date: :desc)

      # 3. 検索パラメータ（生徒ID）があれば、さらに絞り込む
      @feedbacks = @feedbacks.where(student_id: params[:student_id]) if params[:student_id].present?

      # 4. 絞り込み用の生徒リストも「自分のグループの生徒」だけにする
      @students = User.where(role: :student)
                      .joins(:group_users)
                      .where(group_users: { group_id: my_group_ids, accepted: true })
                      .distinct
    else
      # 生徒：自分へのフィードバックだけ
      @feedbacks = Feedback.where(student_id: current_user.id).order(lesson_date: :desc)
    end
  end
end
