# frozen_string_literal: true

# spec/support/login_macros.rb
module LoginMacros
  # spec/support/login_macros.rb (例)
  def sign_in_as(user)
    # allow_forgery_protection をテスト実行時のみ一時的にオフにする
    post login_path, params: { email: user.email, password: user.password },
                     headers: { "HTTP_X_CSRF_TOKEN" => "token" } # ダミーのトークンを渡す
  end
end
