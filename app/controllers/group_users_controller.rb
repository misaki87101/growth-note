# frozen_string_literal: true

# app/controllers/group_users_controller.rb
class GroupUsersController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher

  # 承認待ちリストを表示
  def pending
    # 自分が担当している全クラスの、未承認（accepted: false）の生徒を取得
    @pending_group_users = GroupUser.where(group_id: current_user.group_ids, accepted: false).includes(:user, :group)
  end

  # 「承認」ボタンを押した時の処理
  def update
    @group_user = GroupUser.find(params[:id])
    return unless @group_user.update(accepted: true)

    redirect_to pending_group_users_path, notice: "#{@group_user.user.name}さんを承認しました。"
  end

  # 「拒否（削除）」ボタンを押した時の処理
  def destroy
    @group_user = GroupUser.find(params[:id])
    @group_user.destroy
    redirect_to pending_group_users_path, alert: "リクエストを削除しました。"
  end
end
