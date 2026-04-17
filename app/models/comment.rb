# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :feedback, optional: true
  belongs_to :homework, optional: true

  after_create_commit :send_mention_email

  private

  def send_mention_email
    # 本文からメンションを解析
    mentioned_names = content.scan(/@([^　、。！？!?,]+)/).flatten.map(&:strip)
    mentioned_users = User.where(name: mentioned_names)

    mentioned_users.each do |mentioned_user|
      # 自分自身へのメンションは送らない
      next if mentioned_user == user

      # メーラーを呼び出す
      # コントローラーではないので params ではなく直接引数で渡すか、with を使います
      CommentMailer.with(user: mentioned_user, comment: self).mention_email.deliver_later
    end
  end
end
# 💡 以下のコールバックとメソッドをコメントアウト（または削除）します
# これを止めれば、DBに不要な通知データが溜まりません。

# after_create :create_mention_notifications

# def create_mention_notifications
#   names = content.scan(/@([^\s　、。！？!?,]+)/).flatten
#   names.each do |name|
#     user = User.find_by(name: name)
#     if user && user != self.user
#       Notification.create!(
#         recipient: user,
#         actor: self.user,
#         action: "mention",
#         notifiable: self
#       )
#     end
#   end
# end
