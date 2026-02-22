class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # 💡 デフォルトは生徒（student）にする（enum設定があれば自動で入りますが念のため）
    # @user.role = :student if @user.respond_to?(:role)

    if @user.save
      log_in @user # 💡 登録後すぐにログイン状態にする
      flash[:notice] = "アカウントを作成しました！"
      redirect_to mypage_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # プロフィール表示画面
  def show
    @user = User.find(params[:id])
  end

  # プロフィール編集画面
  def edit
    @user = User.find(params[:id])
    # 自分以外のプロフィールを編集できないようにする（セキュリティ）
    unless @user == current_user || current_user.teacher?
      redirect_to root_path, alert: "権限がありません"
    end
  end

  # プロフィール更新処理
  def update
    @user = User.find(params[:id])
    # セキュリティ：自分自身、または講師だけが削除できるようにする
    if @user == current_user || current_user.teacher?
      @user.destroy
      
      # 自分のアカウントを消した場合はログアウトさせてトップへ
      if @user == current_user
        log_out 
        redirect_to root_path, notice: "ご利用ありがとうございました。アカウントを削除しました。", status: :see_other
      else
        # 講師が生徒を消した場合は生徒一覧へ戻る
        redirect_to users_path, notice: "ユーザーを削除しました。", status: :see_other
      end
    else
      redirect_to root_path, alert: "権限がありません"
    end
  end

  def index
    # 講師が見るための「生徒一覧」なので、roleがstudentの人だけを取得
    @students = User.where(role: :student).order(:name)
  
    # 念のため、生徒がこのページを見ようとしたらマイページへ飛ばす（セキュリティ）
    unless current_user.teacher?
      redirect_to mypage_path, alert: "権限がありません"
    end
  end

  def destroy
    @user = User.find(params[:id])
    # 自分のアカウントか、講師権限がある場合のみ削除可能にする
    if @user == current_user || current_user.teacher?
      @user.destroy
      # 自分のアカウントを消した場合はログアウトさせる
      log_out if @user == current_user
      flash[:notice] = "ユーザーを削除しました"
      redirect_to root_path, status: :see_other
    else
      redirect_to root_path, alert: "権限がありません"
    end
  end


  private

  # ここが重要！追加した項目を許可する
  private

  def user_params
    params.require(:user).permit(
      :name, :email, :role, 
      :bio, :goals, 
      :features, :favorite_things, :message,
      :password, :password_confirmation
    )
  end
end

