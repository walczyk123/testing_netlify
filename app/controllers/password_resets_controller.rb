class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit,:update]
  before_action :valid_user, only: [:edit,:update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
    email_sent_msg = "An email has been sent with a link to reset the password"
    wrong_email_msg = "Email not found in database"
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info]  = email_sent_msg
      redirect_to root_url
    else
      flash.now[:danger] = wrong_email_msg
      render "new"
    end
  end

  def update
    if params[:user][:password].empty?    # case 1 - empty password (looks successful but isn't)
      @user.errors.add(:password, "Password can't be empty")
      render "edit"
    elsif @user.update(user_params)       # case 2 - successful password change
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else                                  # case 3 - invalid password
      render "edit"
    end
  end

  #================== private ===================
  private
  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  def user_params
    params.require(:user).permit(:password,:password_confirmation)
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger]="Password reset has expired."
      redirect_to new_password_reset_url
    end
  end

end
