class PasswordResetsController < ApplicationController
  skip_before_filter :access_validation

  def create
    user = User.find_by_email(params[:email])
  	if user
      if user.account_status == "Disabled"
        flash.now[:danger] = "This account is diabled, please enter a valid email address."
        render 'new'
      else
        user.send_password_reset
        flash[:success] = "Please check your email for password reset instructions."
        redirect_to new_session_path
      end
  	else
      flash.now[:danger] = "No account found with this email address."
  		render 'new'
  	end
  end


  def edit
    @user = User.find_by_reset_digest(params[:id])
    if !@user.present?
      flash[:error] = "The password reset link is not valid."
      redirect_to new_session_path
    elsif @user.reset_sent_at < 30.minutes.ago
      flash[:error] = "The password reset link has expired."
      redirect_to new_session_path
    end
  end


  def update
    @user = User.find_by_reset_digest!(params[:id])
    if @user.reset_sent_at < 2.hour.ago
      flash[:error] = "Password reset has expired"
      redirect_to new_password_reset_path
    elsif @user.update_attributes(params[:user])
      flash[:success] = "Password has been reset!"
      redirect_to new_session_path
    else
      flash[:error] = @user.errors.full_messages.to_sentence
      render :edit
    end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:password)
    end

end
