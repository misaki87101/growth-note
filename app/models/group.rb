# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users
  has_many :boards, dependent: :destroy

  before_create :generate_invitation_code

  private

  def generate_invitation_code
    # 重複しない6桁のランダムな英数字を生成
    loop do
      self.invitation_code = SecureRandom.alphanumeric(6).upcase
      break unless Group.exists?(invitation_code: invitation_code)
    end
  end
end
