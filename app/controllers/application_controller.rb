class ApplicationController < ActionController::Base
  include SessionsHelper
  def hello
    render html: "witaj w mojej karczmie"
  end
  # adding user to main page (experiment)
  # def show
  #   @user = User.find(params[:id])
  # end
  # private
  #   def user_params
  #     params.require(:user).permit(:name,:email,:password,:password_confirmation)
  #   end
  #
  private

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Easy easy, may I check your ID?"
      redirect_to login_url
    end
  end

end
