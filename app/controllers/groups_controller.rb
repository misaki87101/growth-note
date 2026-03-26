# frozen_string_literal: true

# app/controllers/groups_controller.rb
class GroupsController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher

  def show
    @group = Group.find(params[:id])
    # そのクラスに所属している「承認済み」の生徒一覧
    @users = @group.users.where(group_users: { accepted: true })
  end

  def new
    @group = Group.new
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

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
