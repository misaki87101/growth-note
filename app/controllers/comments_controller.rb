# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :logged_in_user

  def edit
    @comment = Comment.find(params[:id])
    return if @comment.user == current_user

    redirect_to root_path, alert: "権限がありません"
  end

  def create
    # どっちのIDが送られてきたかによって、親（@commentable）を切り替える
    if params[:feedback_id]
      @commentable = Feedback.find(params[:feedback_id])
      redirect_target = @commentable
    elsif params[:board_id]
      @commentable = Board.find(params[:board_id])
      # 掲示板の場合は詳細画面(show)などに戻る設定に合わせてください
      redirect_target = @commentable
    end

    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      flash[:success] = "コメントを投稿しました"
      redirect_to redirect_target
    else
      # 失敗時は元の画面へ
      redirect_back_or_to(root_path, alert: "コメントの投稿に失敗しました")
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
      # コメントが紐付いている方にリダイレクト
      redirect_to(@comment.feedback || @comment.board || root_path)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    # リダイレクト先を削除前に確保しておく
    target = @comment.feedback || @comment.board || root_path

    @comment.destroy if @comment.user == current_user
    flash[:success] = "コメントを削除しました"
    redirect_to target, status: :see_other
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
