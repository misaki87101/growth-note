# frozen_string_literal: true

module Homeworks
  class CommentsController < ApplicationController
    # 1. まずログインしているか確認、その後に宿題をセットする順番にする
    before_action :logged_in_user
    before_action :set_homework

    # 💡 不足していた edit アクションを追加
    def edit
      @comment = @homework.comments.find(params[:id])
      # 本人以外は編集できないようにするガード
      redirect_to @homework, alert: 'Unauthorized' unless @comment.user == current_user
    end

    def create
      @comment = @homework.comments.build(comment_params)
      @comment.user = current_user
      if @comment.save
        redirect_to @homework, notice: 'Commented!'
      else
        redirect_to @homework, alert: 'Failed to comment.'
      end
    end

    # 💡 不足していた update アクションを追加
    def update
      @comment = @homework.comments.find(params[:id])
      if @comment.update(comment_params)
        redirect_to @homework, notice: 'Updated!'
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @comment = @homework.comments.find(params[:id])
      # 本人確認
      if @comment.user == current_user || current_user.teacher?
        @comment.destroy
        # 💡 削除後は Turbo ではなく通常の HTML としてリダイレクトさせる
        redirect_to homework_path(@homework), status: :see_other, notice: 'Deleted!'
      else
        redirect_to @homework, alert: 'Unauthorized'
      end
    end

    private

    def set_homework
      @homework = Homework.find(params[:homework_id])
    end

    def comment_params
      params.require(:comment).permit(:content)
    end
  end
end
