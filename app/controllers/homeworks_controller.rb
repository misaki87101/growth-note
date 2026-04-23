# frozen_string_literal: true

require 'open-uri'

class HomeworksController < ApplicationController
  before_action :set_homework, only: %i[show edit update destroy]

  def index
    if current_user.teacher?
      @students = User.where(role: :student)
      # 🌟 絞り込み条件（params[:student_id]）があれば適用する
      @homeworks = if params[:student_id].present?
                     Homework.where(user_id: params[:student_id])
                   else
                     Homework.all
                   end
      @homeworks = @homeworks.includes(:user).order(lesson_date: :desc)
    else
      @homeworks = current_user.homeworks.order(lesson_date: :desc)
    end
  end

  def show
    @homework = Homework.find(params[:id])

    # 1. この宿題の持ち主（生徒）を取得
    student = @homework.user

    # 2. その生徒が所属しているグループの「講師」だけを取得
    # ※生徒が複数のグループに所属している可能性を考慮して groups を経由します
    teachers = User.joins(:group_users)
                   .where(group_users: { group_id: student.group_ids, accepted: true })
                   .where(role: :teacher)

    # 3. 生徒本人 + 同じクラスの講師たち
    @members = User.where(id: [student.id] + teachers.ids).distinct
  end

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
    # 1. まずは画像抜きで本体を作成（メモリ消費を抑える）
    @homework = current_user.homeworks.new(homework_params.except(:images, :image_urls))

    # 2. 本体を先に保存！
    if @homework.save
      # 3. 保存成功後に画像をアタッチ（失敗しても本体は残る）
      image_urls = params.dig(:homework, :image_urls)
      if image_urls.present?
        image_urls.each do |url|
          # ここでメモリを食うので、1つずつ処理して極力負担を減らす
          file = URI.open(url)
          @homework.images.attach(io: file, filename: File.basename(url))
        rescue StandardError => e
          logger.error "Homework image attach error: #{e.message}"
        end
      end

      # 4. 最後にメール送信（画像処理が終わった後なのでメモリ競合が少ない）
      send_homework_emails(@homework)

      redirect_to @homework, notice: '宿題を投稿しました！'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    # 1. まずはテキスト情報などを更新（exceptで画像URLを除外）
    if @homework.update(homework_params.except(:images, :image_urls))

      # 2. 更新成功後に画像を追加する（createと同じ安全ロジック）
      image_urls = params.dig(:homework, :image_urls)
      if image_urls.present?
        image_urls.each do |url|
          file = URI.open(url)
          @homework.images.attach(io: file, filename: File.basename(url))
        rescue StandardError => e
          logger.error "Homework image update error: #{e.message}"
        end
      end

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
    @homework = if current_user.teacher?
                  # 先生はデータベースの全宿題から探せる
                  Homework.find(params[:id])
                else
                  # 生徒は自分の宿題の中からしか探せない（セキュリティのため！）
                  current_user.homeworks.find(params[:id])
                end
  end

  def homework_params
    params.require(:homework).permit(:lesson_date, :content, :hour, :minute, :feedback_id, image_urls: [])
  end

  def send_homework_emails(homework)
    target_group = current_user.groups.first
    return if target_group.blank?

    teachers = target_group.users.where(role: :teacher)
    teachers.each do |teacher|
      next if teacher.id == current_user.id

      CommentMailer.with(user: teacher, homework: homework).homework_submitted_email.deliver_later
    end
  end
end
