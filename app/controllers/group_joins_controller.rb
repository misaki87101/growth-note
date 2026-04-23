# frozen_string_literal: true

class GroupJoinsController < ApplicationController
  # authenticate_user! ではなく、ApplicationControllerにある logged_in_user を使う
  before_action :logged_in_user

  def new
    # 招待コードを入力するフォームを表示
  end

  def create
    group = Group.find_by(invitation_code: params[:invitation_code])

    if group
      # ApplicationControllerで定義している current_user を使って保存
      group_user = group.group_users.find_or_initialize_by(user: current_user)
      group_user.accepted = true

      if group_user.save
        redirect_to root_path, notice: "#{group.name} に入室しました！"
      else
        flash.now[:alert] = "入室に失敗しました。"
        render :new
      end
    else
      flash.now[:alert] = "有効な招待コードではありません。"
      render :new
    end
  end
end
