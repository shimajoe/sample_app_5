class UsersController < ApplicationController
  
  def index
    @user = User.all
  end
  
  def show
    @user = User.find(params[:id])
    #よくわからない挙動があればdebuggerをぶち込もう
    #debugger
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)   
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!" #:success key に"Welcome ~~" value
      redirect_to @user # 保存の成功をここで扱う。
    else
      #成功しなかった時はnewアクションに対応したviewが返る
      render 'new'
    end
  end
  
  private
  #コードを強調するための以降のインデント
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
  
end
