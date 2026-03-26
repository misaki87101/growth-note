# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  # 💡 これを追加！ ユーザーをログイン状態にする魔法です
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

  def logged_in_user
    return if logged_in?

    flash[:alert] = "ログインしてください"
    redirect_to login_url, status: :see_other
  end
end
