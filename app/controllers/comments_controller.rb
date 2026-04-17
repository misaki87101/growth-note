# frozen_string_literal: true

# これはFeedback / Homework のコメント管理のコントローラー

class CommentsController < ApplicationController
  before_action :logged_in_user

  def edit
    @comment = Comment.find(params[:id])
    return if @comment.user == current_user

    redirect_to root_path, alert: "権限がありません"
  end

  def create
    # 1. どの親（Feedback / Homework ）に対するコメントか特定する
    @commentable = if params[:feedback_id]
                     Feedback.find(params[:feedback_id])
                   elsif params[:homework_id]
                     Homework.find(params[:homework_id])
                   end

    # 2. 親に紐づくコメントを作成
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    # 3. 保存処理
    if @comment.save
      mentioned_names = @comment.content.scan(/@([^\s　、。！？!?,]+)/).flatten
      mentioned_users = User.where(name: mentioned_names)

      mentioned_users.each do |user|
        next if user.id == current_user.id # 自分へのメンションは送らない

        CommentMailer.with(user: user, comment: @comment).mention_email.deliver_later
      end

      redirect_to @commentable, notice: "コメントを投稿しました"
    else
      # 失敗時は元の画面に戻る
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
