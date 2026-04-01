# frozen_string_literal: true

# app/models/homework.rb
class Homework < ApplicationRecord
  belongs_to :user
  belongs_to :feedback, optional: true # どのレッスンに対する宿題か紐付け
  has_many_attached :images # 生徒が写真を貼れるようにする
  has_many :comments, dependent: :destroy
  validates :lesson_date, presence: true

  def new_arrival?
    created_at > 24.hours.ago
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