# frozen_string_literal: true

class HomeworksController < ApplicationController
  # ここで指定しているアクションが下に全部存在する必要があります！
  before_action :set_homework, only: %i[show edit update destroy]

  def index
    @homeworks = current_user.homeworks.order(lesson_date: :desc)
  end

  def show; end

  def new
    @homework = current_user.homeworks.build
  end

  def edit; end

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
    @homework = current_user.homeworks.find(params[:id])
  end

  def homework_params
    params.require(:homework).permit(:lesson_date, :content, :hour, :minute, :feedback_id, images: [])
  end
end
