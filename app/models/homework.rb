# frozen_string_literal: true

# app/models/homework.rb
class Homework < ApplicationRecord
  belongs_to :user
  belongs_to :feedback, optional: true # どのレッスンに対する宿題か紐付け
  has_many_attached :images # 生徒が写真を貼れるようにする
  validates :lesson_date, presence: true

  def new_arrival?
    created_at > 24.hours.ago
  end
end
