require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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
  
  test "valid signup information" do
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
    #POSTの送信結果に沿って指定されたリダイレクト先に移動
    follow_redirect!
    #users/showテンプレートが描写される
    assert_template 'users/show'
    #flashが空でないかのテスト
    assert_not flash.empty?
  end
end
