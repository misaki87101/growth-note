# frozen_string_literal: true

class BoardLikesController < ApplicationController
  def create
    @board_like = current_user.board_likes.create(board_id: params[:board_id])
    redirect_back_or_to(root_path)
  end

  def destroy
    @board_like = current_user.board_likes.find_by(board_id: params[:board_id])
    @board_like.destroy
    redirect_back_or_to(root_path)
  end
end
