require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_select "div.alert", "The form contains 4 errors."
    assert_template 'users/edit'
  end 
  
  test "successful edit with friendly forwarding" do
    # edit_user_path(@user)にgetのリクエスト
    get edit_user_path(@user)
    # session[:forwarding_url]とedit_user_url(@user)が等しい時にtrue
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    # session[:forwarding_url]がnilの時true
    assert_nil session[:forwarding_url]
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
  
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
