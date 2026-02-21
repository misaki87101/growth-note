class LikesController < ApplicationController
  before_action :logged_in_user

  def create
    @feedback = Feedback.find(params[:feedback_id])
    # まだいいねしていなければ作成
    current_user.likes.create(feedback_id: @feedback.id)
    # 💡 画面をリロードせずに更新（Turbo）するために、元のページに戻す
    redirect_back(fallback_location: root_path)
  end

  def destroy
    @feedback = Feedback.find(params[:feedback_id])
    like = current_user.likes.find_by(feedback_id: @feedback.id)
    like.destroy if like
    redirect_back(fallback_location: root_path)
  end
end