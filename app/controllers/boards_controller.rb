# frozen_string_literal: true

class BoardsController < ApplicationController
  # cleanup_users を before_action の対象から外す（重要）
  before_action :set_board, only: %i[show edit update destroy]

  def index
    @boards = Board.where(group_id: current_user.groups.pluck(:id)).order(created_at: :desc)
  end

  def show; end

  def new
    @board = Board.new
    @user_groups = current_user.groups
  end

  def edit
    @user_groups = current_user.groups # 編集画面でもグループ選択が必要な場合
  end

  def create
    @board = current_user.boards.build(board_params)
    # 生徒の場合の安全策
    if current_user.student? && current_user.groups.one?
      @board.group_id = current_user.groups.first.id 
    end

    if @board.save
      redirect_to @board, notice: "投稿しました"
    else
      @user_groups = current_user.groups
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @board.update(board_params)
      redirect_to board_path(@board), notice: "掲示板を更新しました"
    else
      @user_groups = current_user.groups # バリデーションエラー時の再表示用
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
    image.purge
    redirect_to edit_board_path(@board), notice: "画像を削除しました"
  end

  private

  def set_board
    @board = Board.find(params[:id])
  end

  def board_params
    # category は enum なので、必要に応じて permit に含める
    params.require(:board).permit(:title, :content, :category, :group_id, images: [])
  end
end