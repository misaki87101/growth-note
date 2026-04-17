# frozen_string_literal: true

class BoardComment < ApplicationRecord
  belongs_to :user
  belongs_to :board

  private

  def send_mention_email
    mentioned_names = content.scan(/@([^\s　、。！？!?,]+)/).flatten
    mentioned_users = User.where("TRIM(name) IN (?)", mentioned_names)

    mentioned_users.each do |mentioned_user|
      next if mentioned_user == user

      # 掲示板コメント用のメールとして送る
      CommentMailer.with(user: mentioned_user, comment: self).mention_email.deliver_later
    end
  end
end
