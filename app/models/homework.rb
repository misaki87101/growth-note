# frozen_string_literal: true

# app/models/homework.rb
class Homework < ApplicationRecord
  belongs_to :user
  belongs_to :feedback, optional: true # どのレッスンに対する宿題か紐付け
  has_many_attached :images # 生徒が写真を貼れるようにする

  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  validates :lesson_date, presence: true

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  def new_arrival?
    created_at > 24.hours.ago
  end

  def images=(attachables)
    attachables = attachables.compact_blank if attachables.is_a?(Array)
    super
  end

  def display_images
    return [] unless images.attached?

    images.map do |image|
      # image.variable? でHEICやJPGなど「変換可能か」を一括判定
      if image.variable?
        # 💡 .processed を付けることで、表示する瞬間に画像生成を完了させます
        # 💡 format: :jpg でHEICも確実にJPGとして出力
        # 💡 resize_to_limit で表示速度（パフォーマンス）も向上させます
        image.variant(resize_to_limit: [300, 300], format: :jpg)
      else
        # 動画やPDFなど、リサイズできないファイルが混ざった場合の安全策
        image
      end
    end
  rescue StandardError => e
    # 万が一、libvipsの変換でエラーが起きても画面が止まらないようにログを出して元の画像を返す
    Rails.logger.error "Image processing error: #{e.message}"
    images
  end
end
