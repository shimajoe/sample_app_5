require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links when not logged in" do
    get root_path
    # 特定のHTMLタグが存在する　タグの種類(a href), リンク先のパス, タグの数
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    # 特定のHTMLタグが存在する　タグの種類（title）, タイトルの文字（full_titleヘルパーを呼び出し）
    assert_select "title", full_title("Contact")
    get signup_path
    # 特定のHTMLタグが存在する　タグの種類（title）, タイトルの文字（full_titleヘルパーを呼び出し）
    assert_select "title", full_title("Sign up")
  end
  
  def setup
    @user = users(:michael)
  end
  
  #ログインしている場合のテスト
  test "layout links when logged in" do
    # ログインする
    log_in_as(@user)
    # root_pathへgetのリクエスト
    get root_path
    # static_pages/homeが描画される
    assert_template 'static_pages/home'
    # 特定のHTMLタグが存在する　タグの種類(a href), リンク先のパス, タグの数
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end
end