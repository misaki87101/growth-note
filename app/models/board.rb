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

  def display_images
    return [] unless images.attached?

    images.map do |image|
      if image.variable?
        image.variant(resize_to_limit: [300, 300], format: :jpg).processed
      else
        image
      end
    end
  rescue StandardError => e
    Rails.logger.error "Image processing error: #{e.message}"
    images
  end

  attribute :category, :integer, default: 0
  enum :category, {
    general: 0,
    question: 1,
    news: 2,
    technique: 3,
    items: 4,
    other: 5
  }

  def category_i18n
    { "general" => "雑談", "question" => "質問", "news" => "お知らせ" }[category]
  end

  def new_arrival?
    created_at > 24.hours.ago
  end

  def images=(attachables)
    attachables = attachables.compact_blank if attachables.is_a?(Array)
    super
  end

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
end
