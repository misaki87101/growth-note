class FeedbacksController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher_user, only: [:new, :create, :edit, :update, :destroy]

  def index
  @students = Student.all # 絞り込み用のリスト

  if params[:student_id].present?
    # 生徒が選択されている場合
    @feedbacks = Feedback.where(student_id: params[:student_id]).order(lesson_date: :desc)
  else
    # 何も選ばれていない場合は全て表示
    @feedbacks = Feedback.all.order(lesson_date: :desc)
  end
end

  def new
    @feedback = Feedback.new
    # フォームの選択肢用に生徒一覧を取得（roleがstudentの人だけ）
    @students = User.where(role: :student)
    # 最初から2つ○、△、×評価の入力欄を表示
    2.times { @feedback.check_items.build }
  end

  def create
    @feedback = Feedback.new(feedback_params)
    # ログイン中の講師のIDを自動セット
    @feedback.teacher_id = current_user.id

    if @feedback.save
      redirect_to feedbacks_path, notice: "フィードバックを投稿しました！"
    else
      @students = User.where(role: :student)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @feedback = Feedback.find(params[:id])

    #【セキュリティ】自分に関係ないフィードバックをURL手打ちで見られないようにする
    unless current_user.teacher? || @feedback.student_id == current_user.id
      redirect_to mypage_path, alert: "閲覧権限がありません"
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
    @students = User.where(role: :student) # フォームの再表示用
    # 編集時、項目が空なら1つ追加しておく
    @feedback.check_items.build if @feedback.check_items.blank?
    # セキュリティ：自分宛のフィードバックじゃない生徒が編集しようとしたら追い返す
    if current_user.student? && @feedback.student_id != current_user.id
      redirect_to mypage_path, alert: "権限がありません"
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
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_path, notice: "フィードバックを削除しました", status: :see_other
  end

  private

  def feedback_params
    params.require(:feedback).permit(
      :student_id, :lesson_date, :content, :rating, :title, :hour, :minute,
      check_items_attributes: [:id, :name, :result, :timestamp, :_destroy]
      )
  end

  def ensure_teacher_user
    unless current_user.teacher?
      flash[:alert] = "講師専用の機能です"
      redirect_to mypage_path
    end
  end
end
