require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup #各テストが実行される直前で実行される
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
    #@userにUserクラスのインスタンス（上記のダミー入り）を代入
  end
  
  test "should be valid" do
    assert @user.valid?
    #有効であればtrue →　@userが有効か？
  end
  
  #user.nameが存在することを確認するテスト
  test "name should be present" do
    @user.name = "     "
    #user.nameに空白を代入
    assert_not @user.valid?
    #falseである　→@userが有効か
  end
  #空白の@user.nameが有効か→falseである　←この時成功するテスト
  #現状は空白でもtrueになってしまう為このtestは成功しない
  
  #emailの存在性
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  #nameの文字制限
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  #emailの文字制限
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  #有効なアドレスの有効性のテスト
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org 
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      #第二引数にエラーメッセージを追加して、どのアドレスでテストが成功しなかったかを特定できるようにしている
      ##{valid_address.inspect}　→　テストが成功しなかったアドレスが変数展開される
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  #バリデーションが設定されていないのでエラーが出ない→有効のテストは成功する
  
  #無効なアドレスの無効性のテスト
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar..com foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  #バリデーションが設定されていないのでエラーが出ない→無効のテストは成功しないのでRED
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup #duplicate_user に @user.dup（@userの複製）を代入
    duplicate_user.email = @user.email.upcase #emailアドレスは大文字小文字区別しない → 大文字に揃える
    @user.save
    assert_not duplicate_user.valid?
    #falseである　→duplicate_user（@userを複製したデータ）は有効か？
  end
  
  
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end
  
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  #@user.password = @user.password_confirmationに空白を6個代入した時
  #@userは有効か　→　Falseである　と言うテスト
  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  #@user.password = @user.password_confirmationにaを5個代入した時
  #@userは有効か　→　Falseである　と言うテスト
  
  
end
