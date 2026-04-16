# frozen_string_literal: true

# app/mailers/comment_mailer.rb
class CommentMailer < ApplicationMailer
  # 送信元のメールアドレス（後で環境に合わせて設定しますが、一旦デフォルトを）
  default from: 'notifications@growthnote.com'

  # メンション用
  def mention_email
    @user = params[:user]       # メンションされた人
    @comment = params[:comment] # コメント内容
    @actor = @comment.user      # 書いた人

    mail(
      to: @user.email,
      subject: "【Growth Note】#{@actor.name}さんからメンションが届きました"
    )
  end

  # フィードバック作成用
  def feedback_created_email
    @student = params[:user] # 送信先（生徒）
    @feedback = params[:feedback]
    @teacher = @feedback.teacher # 担当の先生

    mail(
      to: @student.email,
      subject: "【Growth Note】新しいフィードバックが届きました"
    )
  end
end
