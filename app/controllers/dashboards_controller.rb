# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :logged_in_user

  def show
    # 💡 .with_attached_images を追加して、画像データも一緒に読み込むようにします
    @feedbacks = Feedback.where(student_id: current_user.id)
                         .with_attached_images
                         .order(lesson_date: :desc)
  end
end
