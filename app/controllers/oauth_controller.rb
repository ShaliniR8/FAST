require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController
  skip_before_filter :authenticate_user!


  protected
  # Override this to match your authorization page form
  # It currently expects a checkbox called authorize
  def user_authorizes_token?
    params[:authorize] == '1'
  end

  # should authenticate and return a user if valid password.
  # This example should work with most Authlogic or Devise. Uncomment it
  def authenticate_user(username,password)
    Rails.logger.info "authenticate_user"
    user = User.authenticate(username, password)
    if user
      Rails.logger.info user.inspect
      session[:user_id] = user.id
      session[:platform] = Transaction::PLATFORMS[:mobile]
      define_session_permissions
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

  def oauth2_error(error = 'Wrong username or password.')
    render :json => { :error => error }.to_json, :status => 400
  end

end
