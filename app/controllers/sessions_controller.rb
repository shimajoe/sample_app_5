class SessionsController < ApplicationController
  
  def new
    #debugger
  end
  
  def create #createアクション
    @user = User.find_by(email: params[:session][:email].downcase)
    #userが存在する　かつ　postされたsessionが持つパスワードがそのuserのものと一致する
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      #SessionsHelperで定義したredirect_back_orメソッドを呼び出してリダイレクト先を定義
      redirect_back_or @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new' #ビューnewを描写する
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
