ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper
  
  # Add more helper methods to be used by all tests here...
  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
end
  #log_in_asを何かあった時のために同じ場所にまとめておく
class ActionDispatch::IntegrationTest
  # テストユーザーとしてログインする
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end

