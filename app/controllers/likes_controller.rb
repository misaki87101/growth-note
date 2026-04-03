# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    # 宿題へのいいねか、フィードバックへのいいねかを判別する
    if params[:homework_id]
      @likable = Homework.find(params[:homework_id])
    elsif params[:feedback_id]
      @likable = Feedback.find(params[:feedback_id])
    end

    # @likable（宿題またはフィードバック）に対していいねを作成
    @like = @likable.likes.build(user: current_user)

    if @like.save
      redirect_back_or_to(root_path, notice: 'Liked!')
    else
      redirect_back_or_to(root_path, alert: 'Failed to like.')
    end
  end

  def destroy
    if params[:homework_id]
      @likable = Homework.find(params[:homework_id])
    elsif params[:feedback_id]
      @likable = Feedback.find(params[:feedback_id])
    end

    like = @likable.likes.find_by(user: current_user)
    like&.destroy
    redirect_back_or_to(root_path, notice: 'Unliked!', status: :see_other)
  end
end
