# frozen_string_literal: true

# app/controllers/teacher/approvals_controller.rb (一例)
def index
  # 自分が担当しているクラスの、承認待ち生徒だけを取得
  @pending_users = GroupUser.where(group: current_user.groups, accepted: false).includes(:user, :group)
end

def update
  @group_user = GroupUser.find(params[:id])
  @group_user.update(accepted: true) # ここで承認！
  redirect_to teacher_approvals_path, notice: "#{@group_user.user.name}さんを承認しました！"
end
