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

  def display_images
  return [] unless images.attached?

  images.map do |image|
    # ファイル名やタイプに heic が含まれるか、大文字小文字を問わずチェック
    if image.content_type.downcase.include?("heic") || image.filename.to_s.downcase.end_with?(".heic")
      # ここで強制的にJPG変換をかける
      image.variant(format: :jpg)
    else
      image
    end
  end
end
end
