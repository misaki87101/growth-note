class Student < User
  # 生徒は一人の講師に所属する
  belongs_to :user
  # 生徒はたくさんのフィードバックをもらう
  has_many :feedbacks, dependent: :destroy
  default_scope { where(role: :student) }
end
