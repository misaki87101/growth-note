# frozen_string_literal: true

# app/controllers/dashboards_controller.rb

class DashboardsController < ApplicationController
  before_action :logged_in_user

  def index
    show # indexが呼ばれたらshowを実行する
  end

  def show
    if current_user.teacher?
      # 先生：全生徒のフィードバックを取得
      @feedbacks = Feedback.all.with_attached_images.order(lesson_date: :desc)
      @students = User.where(role: :student)
    else
      # 💡 修正：student_id が自分のIDであるものを取得するように変更
      # current_user.feedbacks だと teacher_id を見に行ってしまうため
      @feedbacks = Feedback.where(student_id: current_user.id).with_attached_images.order(lesson_date: :desc)
    end
  end
end
