require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    #ユーザー登録ページにアクセス
    get signup_path
    #ブロックで渡されたものを呼び出す前後でUser.countに違いがない
    assert_no_difference 'User.count' do
      #users_pathにpostリクエスト　→　内容は無効なユーザーデータを持つparams[:user]ハッシュ
      post signup_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    #id = "error_explanation"を持つdivがある
    assert_select 'div#error_explanation'
    #class = "alert-danger"を持つdivがある
    assert_select 'div.alert-danger'
    #action = ”/signup”を持つformがある
    assert_select 'form[action="/signup"]'
  end
  
  test "valid signup information with account activation" do
    #signup_pathにgetのリクエスト
    get signup_path
    #ブロック内の処理の前後でUser.countが1増えていればtrue
    assert_difference 'User.count', 1 do
      #users_pathにpostのリクエスト→内容は有効なparamas[:user]ハッシュ
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # 引数の値が等しい　１とActionMailer::Base.deliveriesに格納された配列の数
    assert_equal 1, ActionMailer::Base.deliveries.size
    # userに@userを代入（通常統合テストからはアクセスできないattr_accessorで定義した属性の値にもアクセスできるようになる）
    user = assigns(:user)
    # userが有効ではない
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    # テストユーザーがログインしていない
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    # テストユーザーがログインしていない
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    # テストユーザーがログインしていない
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    # userの値を再取得すると有効化している
    assert user.reload.activated?
    #POSTの送信結果に沿って指定されたリダイレクト先に移動
    follow_redirect!
    #users/showテンプレートが描写される
    assert_template 'users/show'
    #flashが空でないかのテスト
    assert_not flash.empty?
    #テストユーザーがログインしている
    assert is_logged_in?
  end
end
