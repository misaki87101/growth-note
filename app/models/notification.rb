# frozen_string_literal: true

# app/models/notification.rb

class Notification < ApplicationRecord
  # 通知を受け取るユーザー
  belongs_to :recipient, class_name: "User"
  # アクションを起こしたユーザー
  belongs_to :actor, class_name: "User"
  # フィードバックやコメントなど、何に対する通知かを柔軟に紐付け
  belongs_to :notifiable, polymorphic: true

  # 未読のみを取得するスコープ（後で「未読数」を出す時に使います）
  scope :unread, -> { where(read_at: nil) }
end
