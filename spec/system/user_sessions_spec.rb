# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  let(:user) { create(:user) }

  describe "ログイン機能" do
    context "入力値が正常な場合" do
      it "ログインに成功すること" do
        visit login_path
        fill_in 'EMAIL', with: user.email
        fill_in 'PASSWORD', with: 'password' # FactoryBotで設定したパスワード
        click_button 'LOGIN'

        # ログイン成功時のフラッシュメッセージや遷移先を確認
        expect(page).to have_content 'マイページへようこそ！'
        expect(current_path).to eq "/mypage"
      end

      it "ログアウトに成功すること" do
        visit login_path
        fill_in 'EMAIL', with: user.email
        fill_in 'PASSWORD', with: 'password'
        click_button 'LOGIN'

        # ログアウトボタン（またはリンク）をクリック
        click_on 'LOGOUT'

        expect(page).to have_content 'ログアウトしました'
        expect(current_path).to eq login_path
      end
    end

    context "入力値が未入力の場合" do
      it "ログインに失敗すること" do
        visit login_path
        fill_in 'EMAIL', with: ''
        fill_in 'PASSWORD', with: ''
        click_button 'LOGIN'

        expect(page).to have_content 'メールアドレスまたはパスワードが正しくありません'
        expect(current_path).to eq login_path
      end
    end
  end
end
