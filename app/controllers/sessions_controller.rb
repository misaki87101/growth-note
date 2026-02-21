class SessionsController < ApplicationController
  def new
  end

  def create
  user = User.find_by(email: params[:session][:email].downcase)
  if user && user.authenticate(params[:session][:password])
    log_in user
    # 💡 ここで分岐！
    if user.teacher?
      redirect_to feedbacks_path, notice: "講師としてログインしました"
    else
      redirect_to mypage_path, notice: "マイページへようこそ！"
    end
  else
    flash.now[:alert] = 'メールアドレスまたはパスワードが正しくありません'
    render 'new', status: :unprocessable_entity
  end
end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "ログアウトしました", status: :see_other
  end
end
