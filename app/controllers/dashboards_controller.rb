class DashboardsController < ApplicationController
  before_action :logged_in_user

  def show
    @feedbacks = Feedback.where(student_id: current_user.id).order(lesson_date: :desc)
  end
end
