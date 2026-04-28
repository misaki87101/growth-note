# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher_user, except: %i[index show edit update]
  before_action :set_feedback, only: %i[show edit update destroy]

  def index
    if !current_user.teacher? && params[:student_id].present? && params[:student_id].to_i != current_user.id
      redirect_to mypage_path, alert: "他人のログは閲覧できません。"
      return
    end

    if current_user.teacher?
      # 先生：担当生徒の分
      @feedbacks = Feedback.includes(:student, :teacher)
                           .where(group_id: @current_group.id)
                           .order(lesson_date: :desc)

      @students = @current_group.users.where(role: :student)
    else
      # 生徒：自分への「公開済み」フィードバックだけ
      @feedbacks = Feedback.published.where(student_id: current_user.id).order(lesson_date: :desc)
    end

    # 先生用の絞り込み
    return if params[:student_id].blank?

    @feedbacks = @feedbacks.where(student_id: params[:student_id])
  end

  def show
    @feedback = Feedback.find(params[:id])
    @members = User.where(id: [@feedback.teacher_id, @feedback.student_id])

    # 💡 セキュリティ：先生でも「自分のグループのフィードバック」じゃなければ追い出す
    if current_user.teacher?
      unless current_user.groups.exists?(id: @feedback.group_id)
        redirect_to feedbacks_path, alert: "閲覧権限がありません" and return
      end
    elsif @feedback.student_id != current_user.id
      redirect_to mypage_path, alert: "閲覧権限がありません" and return
    end
  end

  def new
    @feedback = Feedback.new
    @groups = current_user.groups

    # 先生ならグループの生徒、生徒なら自分自身をプルダウン候補にする
    @students = if current_user.teacher? || current_user.admin?
                  @current_group.users.where(role: :student)
                else
                  User.where(id: current_user.id)
                end
  end

  # クラスを選択した時に、そのクラスの生徒だけを返す専用のアクション
  def select_group
    @group = Group.find(params[:group_id])
    @students = @group.users.where(role: :student)
    @feedback = Feedback.new

    respond_to do |format|
      format.turbo_stream
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])

    @students = if current_user.teacher? || current_user.admin?
                  @current_group.users.where(role: :student)
                else
                  User.where(id: current_user.id)
                end

    if current_user.student? && @feedback.student_id != current_user.id
      redirect_to mypage_path, alert: "権限がありません" and return
    end

    @groups = current_user.groups
    @feedback.check_items.build if @feedback.check_items.blank?
    @check_items = @feedback.check_items
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.teacher = current_user

    if current_user.teacher?
      @feedback.teacher_id = current_user.id
      student = User.find_by(id: params[:feedback][:student_id])
      @feedback.group_id = student.group_users.where(accepted: true).first&.group_id if student
    else
      @feedback.student_id = current_user.id
      @feedback.teacher_id = nil
      @feedback.group_id = current_user.group_users.where(accepted: true).first&.group_id
    end

    if @feedback.save
      # 💡 公開(published)の場合のみメールを送信
      if @feedback.published?
        CommentMailer.with(user: @feedback.student, feedback: @feedback).feedback_created_email.deliver_later
      end

      redirect_to feedbacks_path, notice: "フィードバックを投稿しました！"
    else
      @groups = current_user.groups
      @students = @current_group.users.where(role: :student)
      render :new, status: :unprocessable_content
    end
  end

  def update
    @feedback = Feedback.find(params[:id])

    if @feedback.update(feedback_params)
      # 💡 「今回公開された」かつ「ステータスが切り替わった、または初めて公開された」時だけ送信
      # saved_change_to_status? を使うと、ステータスが変わった時だけ判定できます
      if @feedback.published? && @feedback.saved_change_to_status?
        CommentMailer.with(user: @feedback.student, feedback: @feedback).feedback_created_email.deliver_later
      end

      redirect_to @feedback, notice: "更新しました！"
    else
      @groups = current_user.groups
      @students = if current_user.teacher? || current_user.admin?
                    @current_group.users.where(role: :student)
                  else
                    User.where(id: current_user.id)
                  end
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
        :secret, :status,
        check_items_attributes: %i[id name result timestamp _destroy]
      )
    else
      params.require(:feedback).permit(
        :hour, :minute,
        check_items_attributes: %i[id timestamp]
      )
    end
  end

  def ensure_teacher_user
    return if current_user.teacher?

    flash[:alert] = "講師専用の機能です"
    redirect_to mypage_path
  end
end
