# frozen_string_literal: true

# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  # 管理者以外が index, new, create, edit, update, destroy にアクセスしたらリダイレクト
  before_action :ensure_admin_user, only: %i[index new create edit update destroy]

  before_action :logged_in_user
  before_action :ensure_teacher

  def index
    @groups = Group.order(:created_at)
  end

  def show
    @group = Group.find(params[:id])
    # そのクラスに所属している「承認済み」の生徒一覧
    @users = @group.users.where(group_users: { accepted: true })
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      # クラスを作った先生自身も、そのクラスのメンバー（承認済み）として登録する
      @group.group_users.create(user: current_user, accepted: true)
      redirect_to group_path(@group), notice: 'クラスを作成しました！招待コードを生徒に共有してください。'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to groups_path, notice: "クラス名を更新しました"
    else
      render :edit
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path, notice: "クラスを削除しました", status: :see_other
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def ensure_admin_user
    return if current_user.admin?

    redirect_to root_path, alert: "管理者権限が必要です。"
  end
end
