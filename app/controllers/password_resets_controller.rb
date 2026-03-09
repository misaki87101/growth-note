# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :get_user,         only: %i[edit update]
  before_action :valid_user,       only: %i[edit update]
  before_action :check_expiration, only: %i[edit update] # 💡 期限切れチェック

  def new; end

  def edit; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワード再設定のメールを送信しました"
      redirect_to root_url
    else
      flash.now[:danger] = "メールアドレスが見つかりません"
      render 'new', status: :unprocessable_content
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "入力してください")
      render 'edit', status: :unprocessable_content
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = "パスワードが更新されました"
      redirect_to mypage_path
    else
      render 'edit', status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーか確認する
  def valid_user
    return if @user&.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  # 期限切れかどうか確認する
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = "有効期限が切れています"
    redirect_to new_password_reset_url
  end
end
