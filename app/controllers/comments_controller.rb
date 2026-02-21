class CommentsController < ApplicationController
  before_action :logged_in_user

  def create
    @feedback = Feedback.find(params[:feedback_id])
    @comment = @feedback.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      flash[:success] = "コメントを投稿しました"
      redirect_to @feedback
    else
      redirect_to @feedback
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy if @comment.user == current_user
    flash[:success] = "コメントを削除しました"
    redirect_back(fallback_location: root_path)
  end

  def edit
    @comment = Comment.find(params[:id])
    # セキュリティ：自分のコメント以外は編集できないようにする
    unless @comment.user == current_user
      redirect_to root_path, alert: "権限がありません"
    end
  end

  def update
    @comment = Comment.find(params[:id])
    unless @comment.user == current_user
      redirect_to root_path, alert: "権限がありません"
      return
    end
    if @comment.update(comment_params)
      flash[:success] = "コメントを更新しました"
      redirect_to @comment.feedback
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def comment_params
      params.require(:comment).permit(:content)
    end
end
