Rails.application.routes.draw do
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


  # 生徒用：マイページ
  get 'mypage', to: 'dashboards#show'

  # 利用規約とプライバシーポリシー
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'

  # トップページ（ログインしていなければログイン画面へ）
  root 'application#top'

  # パスワードリセット機能
  resources :password_resets, only: [:new, :create, :edit, :update]

  if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end