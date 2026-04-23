# frozen_string_literal: true

require 'open-uri'

class BoardsController < ApplicationController
  before_action :set_board, only: %i[show edit update destroy]

  def index
    @boards = Board.where(group_id: current_user.groups.pluck(:id)).order(created_at: :desc)
  end

  def show
    @board = Board.find(params[:id])
    # 掲示板が所属するグループのユーザー全員を取得（プルダウン用）
    @members = @board.group.users.distinct
  end

  def new
    @board = Board.new
    @user_groups = current_user.groups
  end

  def edit
    @user_groups = current_user.groups
  end

  def create
    @board = current_user.boards.build(board_params.except(:images, :image_urls))

    # 生徒のグループ補完
    if current_user.student? && @board.group_id.blank? && current_user.groups.any?
      @board.group_id = current_user.groups.first&.id
    end

    # 1. まず本体を保存！
    if @board.save
      # 2. 保存成功後に画像URLを処理
      image_urls = params[:image_urls] ||
                   params.dig(:board, :image_urls) ||
                   params.dig(:homework, :image_urls)

      if image_urls.present?
        image_urls.each do |url|
          file = URI.open(url) # URI.parse(url).open より URI.open の方が推奨
          @board.images.attach(io: file, filename: File.basename(url))
        rescue StandardError => e
          logger.error "Board image attach error: #{e.message}"
        ensure
          file&.close # メモリ節約のため閉じる
        end
        GC.start # メモリ掃除
      end

      # 3. 最後にメール
      members = @board.group.users.where.not(id: current_user.id)
      members.each do |member|
        CommentMailer.with(user: member, board: @board).board_created_email.deliver_later
      end

      redirect_to @board, notice: "掲示板を投稿しました"
    else
      @user_groups = current_user.groups
      render :new, status: :unprocessable_content
    end
  end

  def update
    image_urls = params[:image_urls] ||
                 params.dig(:board, :image_urls) ||
                 params.dig(:homework, :image_urls)

    if image_urls.present?
      image_urls.each do |url|
        file = URI.parse(url).open
        file_name = File.basename(url)
        @board.images.attach(io: file, filename: file_name)
      rescue StandardError => e
        logger.error "Image attach error: #{e.message}"
      end
    end

    if @board.update(board_params.except(:images))
      redirect_to board_path(@board), notice: "掲示板を更新しました"
    else
      @user_groups = current_user.groups
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
    params.require(:board).permit(:title, :content, :category, :group_id, images: [], image_urls: [])
  end
end
