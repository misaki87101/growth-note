# frozen_string_literal: true

# app/controllers/homeworks/comments_controller.rb
module Homeworks
  class CommentsController < ApplicationController
    before_action :set_homework

    def create
      @comment = @homework.comments.new(comment_params)
      @comment.user = current_user
      if @comment.save
        redirect_to homework_path(@homework), notice: "コメントを投稿しました"
      else
        redirect_to homework_path(@homework), alert: "コメントの投稿に失敗しました"
      end
    end

    # 必要に応じて edit, update, destroy も Feedback 用を参考に Homeworks:: 空間に作成します

    private

    def set_homework
      @homework = Homework.find(params[:homework_id])
    end

    def comment_params
      params.require(:comment).permit(:content)
    end
  end
end
