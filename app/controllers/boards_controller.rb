class BoardsController < ApplicationController
  before_action :set_board, only: %i[show edit update destroy]

  def index
    @boards = Board.all.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    @board = Board.new
  end

  def edit
  end

  def create
    @board = current_user.boards.build(board_params)
    if @board.save
      redirect_to boards_path, notice: "掲示板を投稿しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @board.update(board_params)
      redirect_to board_path(@board), notice: "掲示板を更新しました"
    else
      render :edit, status: :unprocessable_entity
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
    params.require(:board).permit(:title, :content, :category, images: [])
  end
end