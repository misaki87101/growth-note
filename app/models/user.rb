# frozen_string_literal: true

class User < ApplicationRecord
  attr_accessor :reset_token

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password, length: { minimum: 6 }, allow_nil: true, on: :update

  # roleの設定を追加（0を講師、1を生徒とする）
  enum :role, { teacher: 0, student: 1 }

  # 講師（teacher）としての関連付け
  # has_many :students, foreign_key: 'user_id', dependent: :destroy
  has_many :feedbacks, foreign_key: 'teacher_id', dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :homeworks, dependent: :destroy
  has_many :boards, dependent: :destroy
  has_many :board_comments, dependent: :destroy
  has_many :board_likes, dependent: :destroy

  # パスワード再設定用の属性を設定する
  def create_reset_digest
    self.reset_token = SecureRandom.urlsafe_base64
    update_columns(reset_digest: BCrypt::Password.create(reset_token), reset_sent_at: Time.zone.now)
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # 再設定の有効期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def teacher?
    self.role == "teacher"
  end
end
