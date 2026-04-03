# frozen_string_literal: true

class Feedback < ApplicationRecord
  belongs_to :student, class_name: 'User', optional: true
  belongs_to :teacher, class_name: 'User', optional: true

  # validates :content, presence: true
  validates :student_id, presence: true
  # validates :teacher_id, presence: true
  validates :lesson_date, presence: true
  validates :title, presence: true

  has_many :check_items, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many_attached :images

  accepts_nested_attributes_for :check_items,
                                allow_destroy: true,
                                reject_if: :all_blank

  def new_arrival?
    created_at > 24.hours.ago
  end

  # 💡 すでに特定のユーザーがいいねしているか判定するメソッド
  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  # フォームから送られてきた images の中身から空文字を取り除く
  def images=(attachables)
    attachables = attachables.compact_blank if attachables.is_a?(Array)
    super
  end

  def process_image(image)
    image.variant(
      resize_to_limit: [300, 300],
      format: :jpg,
      saver: { strip: true }
    ).processed
  rescue StandardError => e
    Rails.logger.error "Image processing failed: #{e.message}"
    image # 失敗した場合は加工前の画像を返す
  end

  def display_images
    return [] unless images.attached?

    images.map do |image|
      # 💡 heic/heif を条件に加えることで、変換対象として強制的に認識させます
      if image.variable? || image.content_type == 'image/heic' || image.content_type == 'image/heif'
        # .processed を付けることでリサイズ画像をキャッシュし、
        # saver: { strip: true } で不要なメタデータを削除して軽量化します
        image.variant(resize_to_limit: [300, 300], format: :jpg, saver: { strip: true }).processed
      else
        # 変換できないファイル（PDFなど）はそのまま返す
        image
      end
    rescue StandardError => e
      Rails.logger.error "Feedback Image processing error: #{e.message}"
      image
    end
  end
end
