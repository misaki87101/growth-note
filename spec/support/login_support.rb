# spec/support/login_support.rb
module LoginSupport
  def sign_in_as(user)
    post login_path, params: { session: { email: user.email, password: user.password || 'password' } }
  end
end

RSpec.configure do |config|
  config.include LoginSupport, type: :request
end