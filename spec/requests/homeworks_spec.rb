require 'rails_helper'

RSpec.describe "Homeworks", type: :request do
  let(:student) { create(:user, role: :student) }
  let(:other_student) { create(:user, role: :student) }

  describe "POST /homeworks" do
    context "ログインしている場合" do
      let(:student) { create(:user, role: :student, password: 'password') }
      
      before { sign_in_as student }

      xit "宿題を投稿できること" do
        homework_params = {
          homework: {
            lesson_date: Date.today,
            content: "テスト投稿",
            hour: 2,
            minute: 0
          }
        }
        puts "--------- エラー内容確認 ---------"
        puts response.body if response.status != 302

        # 投稿されることを確認
        expect {
          post homeworks_path, params: homework_params
        }.to change(Homework, :count).by(1)
        
        expect(response).to redirect_to(homeworks_path)
      end
    end

    context "ログインしていない場合" do
      xit "アクセスが拒否（403）されること" do
        post homeworks_path, params: { homework: { content: "無効な投稿" } }
        # redirect_to ではなく response.status を確認する
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end