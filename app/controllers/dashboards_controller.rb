# app/controllers/dashboards_controller.rb

class DashboardsController < ApplicationController
  before_action :logged_in_user

  def index
    if current_user.teacher?
      # 先生は全生徒のフィードバックを取得（画像も一緒に）
      @feedbacks = Feedback.all.with_attached_images.order(lesson_date: :desc)
      @students = User.where(role: :student)
    else
      # 生徒は自分のフィードバックのみ取得（画像も一緒に）
      @feedbacks = current_user.feedbacks.with_attached_images.order(lesson_date: :desc)
    end
  end
  
  def show
    if current_user.teacher?
      # 先生：全生徒のフィードバックを取得（画像も一緒に）
      @feedbacks = Feedback.all.with_attached_images.order(lesson_date: :desc)
      @students = User.where(role: :student)
    else
      # 生徒：自分のフィードバックのみ取得（画像も一緒に）
      @feedbacks = current_user.feedbacks.with_attached_images.order(lesson_date: :desc)
    end
  end
  

  alias_method :index, :show
end