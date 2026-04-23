class SetAdminToMe < ActiveRecord::Migration[7.2]
  def up
    # 本番環境のアドレスを指定して、デプロイ時に自動でアップデートさせる
    user = User.find_by(email: "misaki.0427z@gmail.com")
    user.update(admin: true) if user
  end

  def down
    # 戻す必要がある場合はここ（基本は空でOK）
  end
end