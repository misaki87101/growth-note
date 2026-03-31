Rails.application.routes.draw do
  get "daily_reports/index"
  get "daily_reports/new"
  #get "boards/index"
  #get "boards/show"
  #get "boards/new"
  #get "boards/edit"
  get "homeworks/index"
  get "homeworks/show"
  get "homeworks/new"
  get "homeworks/edit"
  get "static_pages/terms"
  get "static_pages/privacy"
  get "password_resets/new"
  get "password_resets/edit"
  # 基本ページ
  get "users/edit"
  get "users/update"
  get "users/show"
  get "dashboards/show"
  
  # ログイン・会員登録
  get    'signup',  to: 'users#new'
  post   'signup',  to: 'users#create'
  get    'login',   to: 'sessions#new'
  post   'login',   to: 'sessions#create'
  
  # ログアウト（GETもDELETEも受け付ける安全策）
  match  'logout',  to: 'sessions#destroy', via: [:get, :delete]

  resources :homeworks do
    member do
      delete :purge_image
    end
    resources :homeworks, except: [:destroy] # 宿題の管理（生徒が提出、講師が確認）
  end

  # 講師用：フィードバックの管理
  # 💡 resources :feedbacks は一つにまとめます
  resources :feedbacks do
    member do
      delete :purge_image
    end
    collection do
      get :select_group # クラス選択用のルーティング
    end

    # いいね機能（resource と単数形にすることで /likes/create ではなく /likes になります）
    resource :likes, only: [:create, :destroy]
    # コメント機能
    resources :comments, only: [:create, :destroy, :edit, :update]
  end

  # ユーザープロフィールの表示・編集
  resources :users, only: [:show, :edit, :update , :index, :destroy]

  # 掲示板機能
  resources :boards do
    member do
      delete :purge_image
    end
    resource :board_like, only: [:create, :destroy]
    resources :board_comments, only: [:create, :destroy, :edit, :update]
  end

  # 月間分析ページ

  resources :monthly_notes, only: [:create, :update]
  
  resources :daily_reports do
  collection do
    get :analysis
  end
end

  # グループ（生徒のクラス）管理
  resources :groups, only: [:new, :create, :index, :show]

  resources :group_users, only: [:update, :destroy] do
  get :pending, on: :collection # 承認待ち一覧用
end

  # 生徒用：マイページ
  get 'mypage', to: 'dashboards#show'

  # 利用規約とプライバシーポリシー
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'

  # データクリーンアップ用（デプロイ後にすぐ消す！）
  get 'cleanup_users', to: 'dashboards#cleanup_users'

  # トップページ（ログインしていなければログイン画面へ）
  root 'application#top'

  # パスワードリセット機能
  resources :password_resets, only: [:new, :create, :edit, :update]

  # 売上管理
  resources :daily_reports, only: [:index, :new, :create]

  if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end