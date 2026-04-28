# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?, :current_group

  # 全アクションの前に「現在のクラス」を特定する
  before_action :set_current_group

  attr_reader :current_group

  # ユーザーをログイン状態にする魔法
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  def top
    if logged_in?
      if current_user.teacher?
        redirect_to feedbacks_path
      else
        redirect_to mypage_path
      end
    else
      render 'sessions/new'
    end
  end

  def destroy
    log_out
    redirect_to login_path, notice: "ログアウトしました", status: :see_other
  end

  def ensure_teacher
    redirect_to root_path, alert: '権限がありません' unless current_user&.teacher?
  end

  private

  def set_current_group
    return unless logged_in?

    # 1. パラメータに group_id があれば最優先でセッションに保存
    session[:current_group_id] = params[:group_id] if params[:group_id].present?

    # 2. セッションに保存されているID、または自分が所属する最初のクラスを特定
    group_id = session[:current_group_id] || current_user.groups.first&.id

    # 3. 権限チェックを兼ねて取得（自分が所属していないクラスIDがセッションにある場合は無効にする）
    @current_group = current_user.groups.find_by(id: group_id)

    # 4. もしそれでも取得できない（まだどこにも所属していないなど）場合は、最初のクラスを再セット
    return unless @current_group.nil? && current_user.groups.any?

    @current_group = current_user.groups.first
    session[:current_group_id] = @current_group.id
  end

  def logged_in_user
    return if logged_in?

    flash[:alert] = "ログインしてください"
    redirect_to login_url, status: :see_other
  end
end
