# frozen_string_literal: true

class LessonArchivesController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher_user
  before_action :set_lesson_archive, only: %i[show edit update destroy]

  def index
    @lesson_archives = LessonArchive.where(group_id: @current_group.id)
                                    .order(lesson_date: :desc)
  end

  def show
    # ここが「印刷用ページ」のベース
    @feedbacks = @lesson_archive.feedbacks.includes(:student)
  end

  def new
    @lesson_archive = LessonArchive.new(lesson_date: Time.zone.today)
  end

  def edit
    # set_lesson_archive で取得済み
  end

  def create
    @lesson_archive = current_user.lesson_archives.build(lesson_archive_params)

    if @lesson_archive.save
      redirect_to lesson_archives_path, notice: "講習記録を保存しました！"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @lesson_archive.update(lesson_archive_params)
      redirect_to lesson_archives_path, notice: "講習記録を更新しました！"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @lesson_archive.destroy
    redirect_to lesson_archives_path, notice: "講習記録を削除しました", status: :see_other
  end

  private

  def set_lesson_archive
    @lesson_archive = LessonArchive.find(params[:id])
  end

  def lesson_archive_params
    params.require(:lesson_archive).permit(:lesson_date, :title, :schedule, :items, :notice, :status, :group_id)
  end

  def ensure_teacher_user
    return if current_user.teacher?

    redirect_to mypage_path, alert: "講師専用の機能です"
  end
end
