# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :logged_in_user
  before_action :ensure_teacher_user, except: %i[index show edit update]

  def index
    if current_user.teacher?
      # 先生：自分が担当している生徒の分だけ
      @feedbacks = Feedback.where(student_id: current_user.students.ids).order(lesson_date: :desc)
      @students = current_user.students
    else
      # 生徒：自分宛、かつ自分が所属しているクラスの分だけ
      # これで「他クラスのデータ」は一切混ざらなくなります！
      @feedbacks = Feedback.where(student_id: current_user.id, group_id: current_user.group_ids)
                           .order(lesson_date: :desc)
      @students = [] # 生徒には空のリストを渡す
    end

    # 生徒絞り込み検索（先生用）
    return if params[:student_id].blank?

    @feedbacks = @feedbacks.where(student_id: params[:student_id])
  end

  def purge_image
    @feedback = Feedback.find(params[:id])
    image = @feedback.images.find(params[:image_id])
    image.purge
    redirect_to edit_feedback_path(@feedback), notice: "画像を削除しました"
  end

  def show
    @feedback = Feedback.find(params[:id])

    # 【セキュリティ】自分に関係ないフィードバックをURL手打ちで見られないようにする
    return if current_user.teacher? || @feedback.student_id == current_user.id

    redirect_to mypage_path, alert: "閲覧権限がありません"
  end

  def new
    @feedback = Feedback.new
    # 先生が所属しているグループ一覧
    @groups = current_user.groups
    # フォームの選択肢用に生徒一覧を取得（roleがstudentの人だけ）
    @students = []

    # 最初から2つ○、△、×評価の入力欄を表示
    # 2.times { @feedback.check_items.build }
  end

  # クラスを選択した時に、そのクラスの生徒だけを返す専用のアクションを追加
  def select_group
    @group = Group.find(params[:group_id])
    @students = @group.users.where(role: :student)

    respond_to do |format|
      format.turbo_stream # select_group.turbo_stream.erb を探しにいく
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])

    # 【追加】編集画面でも「クラス一覧」が必要な場合に備えて定義
    @groups = current_user.groups

    # 【改善】全生徒ではなく、先生が担当している生徒に絞る（newと同じにするとバグが減ります）
    @students = current_user.teacher? ? current_user.students : []

    # 項目が空なら1つ追加しておく（既存のロジック）
    @feedback.check_items.build if @feedback.check_items.blank?

    # 生徒が他人のフィードバックを編集しようとした時だけガードする
    return unless current_user.student? && @feedback.student_id != current_user.id

    redirect_to mypage_path, alert: "権限がありません"
    nil
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if current_user.teacher?
      @feedback.teacher_id = current_user.id

      # 💡選ばれた生徒が所属しているグループIDをセットする
      # params[:feedback][:student_id] から生徒を探す
      student = User.find_by(id: params[:feedback][:student_id])
      if student
        # その生徒が所属している「承認済み」の最初のグループIDをセット
        @feedback.group_id = student.group_users.where(accepted: true).first&.group_id
      end
    else
      # 生徒自身が投稿する場合（もし今後使うなら）
      @feedback.student_id = current_user.id
      @feedback.teacher_id = nil
      @feedback.group_id = current_user.group_users.where(accepted: true).first&.group_id
    end

    if @feedback.save
      redirect_to feedbacks_path, notice: "フィードバックを投稿しました！"
    else
      # 失敗した時の再表示用データ
      @groups = current_user.groups
      @students = User.where(role: :student) # 必要に応じて絞り込み
      render :new, status: :unprocessable_content
    end
  end

  def update
    @feedback = Feedback.find(params[:id])
    # update内でも同様のチェックを入れる
    if current_user.student? && @feedback.student_id != current_user.id
      redirect_to mypage_path, alert: "権限がありません"
      return
    end

    if @feedback.update(feedback_params)
      redirect_to feedback_path(@feedback), notice: "更新しました！"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_path, notice: "フィードバックを削除しました", status: :see_other
  end

  private

  def feedback_params
    if current_user.teacher?
      params.require(:feedback).permit(
        :student_id, :lesson_date, :content, :rating, :title, :hour, :minute,
        images: [], # 画像の複数アップロードに対応
        check_items_attributes: %i[id name result timestamp _destroy]
      )
    else
      params.require(:feedback).permit(:hour, :minute)
    end
  end

  def ensure_teacher_user
    return if current_user.teacher?

    flash[:alert] = "講師専用の機能です"
    redirect_to mypage_path
  end
end
