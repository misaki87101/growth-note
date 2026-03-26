# frozen_string_literal: true

class Board < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_many_attached :images
  has_many :board_comments, dependent: :destroy

  has_many :board_likes, dependent: :destroy
  # ユーザーがその投稿にいいねしているか判定するメソッド
  def liked_by?(user)
    board_likes.exists?(user_id: user.id)
  end

  attribute :category, :integer, default: 0
  enum :category, { general: 0, question: 1, news: 2 }

  def category_i18n
    { "general" => "雑談", "question" => "質問", "news" => "お知らせ" }[category]
  end

  def new_arrival?
    created_at > 24.hours.ago
  end

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
end
