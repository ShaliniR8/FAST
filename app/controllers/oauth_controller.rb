require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController
  # oauthenticate :strategies => :token , :interactive => true
  skip_before_filter :authenticate_user!
  #before_filter :authenticate_user


  protected
  # Override this to match your authorization page form
  # It currently expects a checkbox called authorize
  def user_authorizes_token?
    params[:authorize] == '1'
  end

  # should authenticate and return a user if valid password.
  # This example should work with most Authlogic or Devise. Uncomment it
  def authenticate_user(username,password)
    #prepend ProviderController
    Rails.logger.info "authenticate_user"
    user = User.authenticate(username, password)
    if user
      Rails.logger.info user.inspect
      session[:user_id] = user.id
      #session[:mode] = "ASAP"
      #Rails.logger.info session.inspect
      #flash[:notice] = "Logged in successfully."
      #if current_user.level == "Employee"
      #  redirect_to(work_requests_path)
      #else
        #redirect_to_target_or_default(root_url)
      #end
    else
      respond_to do |format|
        format.html do
          flash.now[:error] = 'Invalid login or password.'
          render :action => 'new'
        end
        format.json {}
      end
    end
    user
  end

  #alias :login_required :authenticate_user

end
