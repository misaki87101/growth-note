# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :feedback, optional: true
  belongs_to :homework, optional: true

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
end
