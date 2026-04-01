# frozen_string_literal: true

# app/controllers/homeworks/likes_controller.rb
module Homeworks
  class LikesController < ApplicationController
    before_action :set_homework

    def create
      @like = @homework.likes.new(user: current_user)
      return unless @like.save

      redirect_back_or_to(root_path, notice: "いいねしました")
    end

    def destroy
      @like = @homework.likes.find_by(user: current_user)
      @like&.destroy
      redirect_back_or_to(root_path, notice: "いいねを取り消しました")
    end

    private

    def set_homework
      @homework = Homework.find(params[:homework_id])
    end
  end
end
