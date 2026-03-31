# frozen_string_literal: true

class BoardsController < ApplicationController
  before_action :set_board, only: %i[show edit update destroy]

  skip_before_action :authenticate_user!, if: -> { action_name == 'cleanup_users' }
def cleanup_users
    # 名前が「テスト」または特定の条件のユーザーを探して削除
    # もし不安なら、User.destroy_all ですべてリセットしてもOKです
    User.destroy_all
    render plain: "#{count}人のテストユーザーを削除しました。"
  end
end

  def index
    @boards = Board.where(group_id: current_user.group_ids).order(created_at: :desc)
  end

  def show; end

  def new
    @board = Board.new
    @user_groups = current_user.groups
  end

  def edit; end

  def create
    @board = current_user.boards.build(board_params)
    # もし生徒で、所属グループが1つだけなら、パラメータを無視して強制的にそのグループに紐付ける（安全策）
    @board.group_id = current_user.groups.first.id if current_user.student? && current_user.groups.one?

    if @board.save
      redirect_to @board, notice: "投稿しました"
    else
      @user_groups = current_user.groups # 再表示用に必要
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @board.update(board_params)
      redirect_to board_path(@board), notice: "掲示板を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @board.destroy
    redirect_to boards_path, notice: "掲示板を削除しました", status: :see_other
  end

  def purge_image
    @board = Board.find(params[:id])
    image = @board.images.find(params[:image_id])
    image.purge # Active Storageの画像を物理削除
    redirect_to edit_board_path(@board), notice: "画像を削除しました"
  end

  private

  def set_board
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :content, :category, :group_id, images: [])
  end
end
