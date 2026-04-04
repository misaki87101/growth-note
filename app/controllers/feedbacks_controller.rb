# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher_user, except: %i[index show edit update]
  before_action :set_feedback, only: %i[show edit update destroy]

  def index
    if current_user.teacher?
      # 先生：担当生徒の分
      @feedbacks = Feedback.where(student_id: current_user.students.ids).order(lesson_date: :desc)
      @students = current_user.students
    else
      # 💡 修正：group_id の条件を削除し、シンプルに「自分宛」だけにする
      @feedbacks = Feedback.where(student_id: current_user.id).order(lesson_date: :desc)
      @students = []
    end

    # 先生用の絞り込み（ここはそのまま）
    return if params[:student_id].blank?

    @feedbacks = @feedbacks.where(student_id: params[:student_id])
  end

  def show
    @feedback = Feedback.find(params[:id])

    # 【セキュリティ】自分に関係ないフィードバックをURL手打ちで見られないようにする
    return if current_user.teacher? || @feedback.student_id == current_user.id

    redirect_to mypage_path, alert: "閲覧権限がありません"
  end

  def new
    @feedback = Feedback.new
    # 先生が所属しているグループ一覧
    @groups = current_user.groups
    # フォームの選択肢用に生徒一覧を取得（roleがstudentの人だけ）
    @students = []

    # 最初から2つ○、△、×評価の入力欄を表示
    # 2.times { @feedback.check_items.build }
  end

  # クラスを選択した時に、そのクラスの生徒だけを返す専用のアクションを追加
  def select_group
    @group = Group.find(params[:group_id])
    @students = @group.users.where(role: :student)

    respond_to do |format|
      format.turbo_stream # select_group.turbo_stream.erb を探しにいく
    end
  end

  # app/controllers/feedbacks_controller.rb

  def edit
    @feedback = Feedback.find(params[:id])

    # 権限チェック：生徒が他人のものを編集しようとしたらガード
    if current_user.student? && @feedback.student_id != current_user.id
      redirect_to mypage_path, alert: "権限がありません" and return
    end

    # 💡 @students の作り方を修正
    @students = if current_user.teacher?
                  # 先生の場合：自分が担当している全生徒（または今のグループの生徒）
                  current_user.students
                else
                  # 生徒の場合：自分自身をリストに入れる（これでプルダウンに名前が出るようになります）
                  User.where(id: current_user.id)
                end

    @groups = current_user.groups
    @feedback.check_items.build if @feedback.check_items.blank?
    @check_items = @feedback.check_items
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if current_user.teacher?
      @feedback.teacher_id = current_user.id

      # 💡選ばれた生徒が所属しているグループIDをセットする
      # params[:feedback][:student_id] から生徒を探す
      student = User.find_by(id: params[:feedback][:student_id])
      if student
        # その生徒が所属している「承認済み」の最初のグループIDをセット
        @feedback.group_id = student.group_users.where(accepted: true).first&.group_id
      end
    else
      # 生徒自身が投稿する場合（もし今後使うなら）
      @feedback.student_id = current_user.id
      @feedback.teacher_id = nil
      @feedback.group_id = current_user.group_users.where(accepted: true).first&.group_id
    end

    if @feedback.save
      redirect_to feedbacks_path, notice: "フィードバックを投稿しました！"
    else
      # 失敗した時の再表示用データ
      @groups = current_user.groups
      @students = User.where(role: :student) # 必要に応じて絞り込み
      render :new, status: :unprocessable_content
    end
  end

  def update
    @feedback = Feedback.find(params[:id])

    # 2. Homeworksと同じく、一括更新の形にシンプルにする
    # ※ images: [] を feedback_params で許可しているため、これで動きます
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: "更新しました！"
    else
      @groups = current_user.groups
      @students = current_user.teacher? ? current_user.students : User.where(id: current_user.id)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_path, notice: "フィードバックを削除しました", status: :see_other
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def feedback_params
    if current_user.teacher?
      params.require(:feedback).permit(
        :student_id, :lesson_date, :content, :rating, :title, :hour, :minute,
        check_items_attributes: %i[id name result timestamp _destroy]
      )
    else
      params.require(:feedback).permit(
        :hour, :minute,
        check_items_attributes: %i[id timestamp] # 生徒はタイムスタンプだけ更新する想定
      )
    end
  end

  def ensure_teacher_user
    return if current_user.teacher?

    flash[:alert] = "講師専用の機能です"
    redirect_to mypage_path
  end
end
