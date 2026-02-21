class UsersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # 💡 デフォルトは生徒（student）にする（enum設定があれば自動で入りますが念のため）
    @user.role = :student if @user.respond_to?(:role)

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
    if @user.update(user_params)
      # 更新した本人が誰かによって戻り先を変える
      if current_user.teacher?
        redirect_to users_path, notice: "プロフィールを更新しました！"
      else
        redirect_to mypage_path, notice: "プロフィールを更新しました！"
      end
    else
      # 💡 保存に失敗（バリデーション落ち）したらここに来る
      flash.now[:alert] = "更新に失敗しました。入力内容を確認してください。"
      render :edit, status: :unprocessable_entity
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

  private

  # ここが重要！追加した項目を許可する
  def user_params
    params.require(:user).permit(
      :name, :email, :bio, :goals, 
      :features, :favorite_things, :message,
      :password, :password_confirmation
    )
  end
end

