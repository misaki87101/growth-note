# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :logged_in_user, except: %i[new create]
  # 講師以外はユーザー一覧にアクセスできないようにする
  before_action :ensure_teacher_user, only: [:index]

  # ユーザー一覧
  def index
    unless current_user.teacher?
      redirect_to mypage_path, alert: "権限がありません"
      return
    end

    # 1. まずベースの生徒一覧（role: :student）を取得
    @students = User.where(role: :student).order(:name)

    # 2. クラスが選択されている場合、中間テーブルを通して絞り込む
    return if params[:group_id].blank?

    @current_group = Group.find(params[:group_id])
    # 中間テーブル経由でそのクラスのユーザーだけを抽出
    @students = @current_group.users.where(role: :student).order(:name)
  end

  # プロフィール表示
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  # プロフィール編集
  def edit
    @user = User.find(params[:id])
    return if @user == current_user || current_user.teacher?

    redirect_to root_path, alert: "権限がありません"
  end

  # アカウント作成
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:notice] = "アカウントを作成しました！"
      redirect_to mypage_path
    else
      flash.now[:danger] = "入力内容にエラーがあります"
      render :new, status: :unprocessable_content
    end
  end

  # プロフィール更新
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      if current_user.teacher?
        redirect_to users_path, notice: "プロフィールを更新しました！"
      else
        redirect_to mypage_path, notice: "プロフィールを更新しました！"
      end
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_content
    end
  end

  # ユーザー削除
  def destroy
    @user = User.find(params[:id])
    return unless @user == current_user || current_user.teacher?

    # 強制的に紐づくデータを削除する（エラー回避用）
    Feedback.where(teacher_id: @user.id).delete_all if defined?(Feedback)

    @user.destroy
    log_out if @user == current_user
    flash[:notice] = "ユーザーを削除しました"
    redirect_to root_path, status: :see_other
  end

  private

  def ensure_teacher_user
    return if current_user.teacher?

    redirect_to mypage_path, alert: "講師専用の機能です。"
  end

  def user_params
    params.require(:user).permit(
      :name, :email, :role, :bio, :goals,
      :features, :favorite_things, :message,
      :password, :password_confirmation, :invitation_code,
      :birthday
    )
  end
end
