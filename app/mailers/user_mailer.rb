class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "[Growth Note]パスワード再設定のご案内"
  end
end
