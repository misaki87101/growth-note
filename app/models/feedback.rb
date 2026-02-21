class Feedback < ApplicationRecord
  belongs_to :student, class_name: 'User' , optional: true
  belongs_to :teacher, class_name: 'User' , optional: true

  # validates :content, presence: true
  validates :student_id, presence: true
  # validates :teacher_id, presence: true
  validates :lesson_date, presence: true
  validates :title, presence: true

  has_many :check_items, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

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
end
