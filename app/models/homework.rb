# frozen_string_literal: true

# app/models/homework.rb
class Homework < ApplicationRecord
  attr_accessor :image_urls

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
      # image.variable? だけでなく、contentType もチェック対象に含めるとより確実です
      if image.variable? || image.content_type == 'image/heic' || image.content_type == 'image/heif'
        # HEICを強制的に jpg に変換してリサイズ
        image.variant(resize_to_limit: [300, 300], format: :jpg, saver: { strip: true }).processed
      else
        image
      end
    end
  rescue StandardError => e
    Rails.logger.error "Feedback Image processing error: #{e.message}"
    # 壊れた時のために、元の画像をそのまま返す
    images
  end
end
