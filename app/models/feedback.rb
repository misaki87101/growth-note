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
      # image.variable? は「その画像がリサイズや変換可能か」を判定するRailsのメソッドです
      if image.variable?
        # HEICかどうかに関わらず、表示用にリサイズ + JPG固定にしておくと表示が安定します
        # (元のHEICデータはそのまま残り、表示用だけJPGが生成されます)
        image.variant(resize_to_limit: [800, 800], format: :jpg).processed
      else
        # 動画やPDFなど、変換できないファイルが混じった場合の予備
        image
      end
    end
  rescue StandardError
    # 万が一変換エラーが起きても画面が真っ白にならないためのガード
    images
  end
end
