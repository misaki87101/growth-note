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

  # 掲示板投稿用
  def board_created_email
    @user = params[:user]     # 送信先（メンバー一人ひとり）
    @board = params[:board]   # 掲示板の投稿内容
    @sender = @board.user     # 投稿した人

    mail(
      to: @user.email,
      subject: "【Growth Note】掲示板に新しい投稿があります"
    )
  end

  # 宿題提出通知用
  def homework_submitted_email
    @user = params[:user]     # 送信先（先生）
    @homework = params[:homework]
    @student = @homework.user # 提出した生徒

    mail(
      to: @user.email,
      subject: "【Growth Note】#{@student.name}さんが宿題を提出しました"
    )
  end
end
