# frozen_string_literal: true

class BoardComment < ApplicationRecord
  belongs_to :user
  belongs_to :board

  after_create_commit :send_mention_email

  private

  def send_mention_email
    mentioned_names = content.scan(/@([^　、。！？!?,]+)/).flatten.map(&:strip)
    mentioned_users = User.where(name: mentioned_names)

    mentioned_users.each do |mentioned_user|
      next if mentioned_user == user

      # 掲示板コメント用のメールとして送る
      CommentMailer.with(user: mentioned_user, comment: self).mention_email.deliver_later
    end
  end
end
