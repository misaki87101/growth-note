# frozen_string_literal: true

class LessonArchive < ApplicationRecord
  belongs_to :teacher, class_name: 'User'
  belongs_to :group
  has_many :feedbacks, dependent: :nullify

  enum :status, { draft: 0, published: 1 }

  validates :lesson_date, presence: true
  validates :title, presence: true
  validates :status, inclusion: { in: statuses.keys }
end
