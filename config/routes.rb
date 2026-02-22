Rails.application.routes.draw do
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

  # 講師用：フィードバックの管理
  # 💡 resources :feedbacks は一つにまとめます
  resources :feedbacks do
    # いいね機能（resource と単数形にすることで /likes/create ではなく /likes になります）
    resource :likes, only: [:create, :destroy]
    # コメント機能
    resources :comments, only: [:create, :destroy, :edit, :update]
  end

  # ユーザープロフィールの表示・編集
  resources :users, only: [:show, :edit, :update , :index, :destroy]

  # 生徒用：マイページ
  get 'mypage', to: 'dashboards#show'

  # トップページ（ログインしていなければログイン画面へ）
  root 'application#top'

  # パスワードリセット機能
  resources :password_resets, only: [:new, :create, :edit, :update]

  if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end