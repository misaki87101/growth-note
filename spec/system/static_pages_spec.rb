# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "利用規約ページ" do
    it "正常に表示されること" do
      visit terms_path
      expect(page).to have_content '利用規約'
      expect(current_path).to eq terms_path
    end
  end

  describe "プライバシーポリシーページ" do
    it "正常に表示されること" do
      visit privacy_path
      expect(page).to have_content 'プライバシーポリシー'
      expect(current_path).to eq privacy_path
    end
  end
end
