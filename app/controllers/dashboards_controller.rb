# frozen_string_literal: true

# app/controllers/dashboards_controller.rb

class DashboardsController < ApplicationController
  before_action :logged_in_user

  def index
    show # indexが呼ばれたらshowを実行する
  end

  def show
    if current_user.teacher?
      # 2. そのグループに所属している生徒へのフィードバックだけに限定
      @feedbacks = Feedback.includes(:student, :teacher, :lesson_archive)
                           .where(group_id: @current_group.id)
                           .order(lesson_date: :desc)
      # 3. 検索パラメータ（生徒ID）があれば、さらに絞り込む
      @feedbacks = @feedbacks.where(student_id: params[:student_id]) if params[:student_id].present?

      # 4. 絞り込み用の生徒リストも「自分のグループの生徒」だけにする
      @students = @current_group.users.where(role: :student)
    else
      @feedbacks = Feedback.published
                           .includes(:teacher, :lesson_archive)
                           .where(student_id: current_user.id)
                           .order(lesson_date: :desc)
    end
  end
end
