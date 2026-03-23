# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher_user, except: %i[index show edit update]

  def index
    @students = Student.all # 絞り込み用のリスト

    @feedbacks = if params[:student_id].present?
                   # 生徒が選択されている場合
                   Feedback.where(student_id: params[:student_id]).order(lesson_date: :desc)
                 else
                   # 何も選ばれていない場合は全て表示
                   Feedback.order(lesson_date: :desc)
                 end
  end

  def purge_image
  @feedback = Feedback.find(params[:id])
  image = @feedback.images.find(params[:image_id])
  image.purge
  redirect_to edit_feedback_path(@feedback), notice: "画像を削除しました"
end

  def show
    @feedback = Feedback.find(params[:id])

    # 【セキュリティ】自分に関係ないフィードバックをURL手打ちで見られないようにする
    return if current_user.teacher? || @feedback.student_id == current_user.id

    redirect_to mypage_path, alert: "閲覧権限がありません"
  end

  def new
    @feedback = Feedback.new
    # フォームの選択肢用に生徒一覧を取得（roleがstudentの人だけ）
    @students = User.where(role: :student)
    # 最初から2つ○、△、×評価の入力欄を表示
    2.times { @feedback.check_items.build }
  end

  def edit
    @feedback = Feedback.find(params[:id])
    @students = User.where(role: :student) # フォームの再表示用
    # 編集時、項目が空なら1つ追加しておく
    @feedback.check_items.build if @feedback.check_items.blank?
    # セキュリティ：自分宛のフィードバックじゃない生徒が編集しようとしたら追い返す
    return unless current_user.student? && @feedback.student_id != current_user.id

    redirect_to mypage_path, alert: "権限がありません"
  end

  def create
    @feedback = Feedback.new(feedback_params)

    # 💡 保存する前に、誰が投稿したかによってIDを振り分ける
    if current_user.teacher?
      @feedback.teacher_id = current_user.id
      # student_id はフォームから送られてきたもの（feedback_params）が自動で入る想定
    else
      @feedback.student_id = current_user.id
      # 生徒が投稿する場合、teacher_id は空にするか、特定の講師がいればここでセット
      @feedback.teacher_id = nil
    end

    if @feedback.save
      redirect_to feedbacks_path, notice: "フィードバックを投稿しました！"
    else
      @students = User.where(role: :student)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @feedback = Feedback.find(params[:id])
    # update内でも同様のチェックを入れる
    if current_user.student? && @feedback.student_id != current_user.id
      redirect_to mypage_path, alert: "権限がありません"
      return
    end

    if @feedback.update(feedback_params)
      redirect_to feedback_path(@feedback), notice: "更新しました！"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_path, notice: "フィードバックを削除しました", status: :see_other
  end

  private

  def feedback_params
    if current_user.teacher?
      params.require(:feedback).permit(
        :student_id, :lesson_date, :content, :rating, :title, :hour, :minute,
        images: [], # 画像の複数アップロードに対応
        check_items_attributes: %i[id name result timestamp _destroy]
      )
    else
      params.require(:feedback).permit(:hour, :minute)
    end
  end

  def ensure_teacher_user
    return if current_user.teacher?

    flash[:alert] = "講師専用の機能です"
    redirect_to mypage_path
  end
end
