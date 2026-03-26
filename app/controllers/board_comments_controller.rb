# frozen_string_literal: true

class BoardCommentsController < ApplicationController
  def create
    @board = Board.find(params[:board_id])
    @board_comment = @board.board_comments.build(board_comment_params)
    @board_comment.user_id = current_user.id

    if @board_comment.save
      redirect_to board_path(@board), notice: "コメントを投稿しました"
    else
      redirect_to board_path(@board), alert: "コメントの投稿に失敗しました"
    end
  end

  def destroy
    @board_comment = BoardComment.find(params[:id])
    @board_comment.destroy
    redirect_to board_path(@board_comment.board), notice: "コメントを削除しました", status: :see_other
  end

  private

  def board_comment_params
    params.require(:board_comment).permit(:content)
  end
end
