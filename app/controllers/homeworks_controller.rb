# frozen_string_literal: true

class HomeworksController < ApplicationController
  # ここで指定しているアクションが下に全部存在する必要があります！
  before_action :set_homework, only: %i[show edit update destroy]

  def index
    if current_user.teacher?
      @students = User.where(role: :student)
      # 🌟 絞り込み条件（params[:student_id]）があれば適用する
      if params[:student_id].present?
        @homeworks = Homework.where(user_id: params[:student_id])
      else
        @homeworks = Homework.all
      end
      @homeworks = @homeworks.includes(:user).order(lesson_date: :desc)
    else
      @homeworks = current_user.homeworks.order(lesson_date: :desc)
    end
  end

  def show; end

  def new
    @homework = current_user.homeworks.build
  end

  def edit; end

  def purge_image
  @homework = Homework.find(params[:id])
  image = @homework.images.find(params[:image_id])
  image.purge
  redirect_to edit_homework_path(@homework), notice: "画像を削除しました"
end

  def create
    @homework = current_user.homeworks.build(homework_params)
    if @homework.save
      redirect_to homeworks_path, notice: "宿題を提出しました！"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @homework.update(homework_params)
      redirect_to homework_path(@homework), notice: "宿題を更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @homework.destroy
    redirect_to homeworks_path, notice: "削除しました"
  end

  private

  def set_homework
    if current_user.teacher?
      # 先生はデータベースの全宿題から探せる
      @homework = Homework.find(params[:id])
    else
      # 生徒は自分の宿題の中からしか探せない（セキュリティのため！）
      @homework = current_user.homeworks.find(params[:id])
    end
  end

  def homework_params
    params.require(:homework).permit(:lesson_date, :content, :hour, :minute, :feedback_id, images: [])
  end
end
