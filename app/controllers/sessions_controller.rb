class SessionsController < ApplicationController
  
  def new
  end
  
  def create #createアクション
    user = User.find_by(email: params[:session][:email].downcase)
    #userが存在する　かつ　postされたsessionが持つパスワードがそのuserのものと一致する
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user #ヘルパーメソッドlog_in
      redirect_to user #user_url(user)
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new' #ビューnewを描写する
    end
  end
  
  def destroy
    log_out
    redirect_to root_url
  end
end
