# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
#
#   <% if logged_in? %>
#     Welcome <%= current_user.username %>.
#     <%= link_to "Edit profile", edit_current_user_path %> or
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
#
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required, :except => [:index, :show]
module ControllerAuthentication

  def self.included(controller)
    controller.send :helper_method, :current_user, :logged_in?, :redirect_to_target_or_default, :redirect_back_or_default
  end


  def current_user
    # Rails.logger.debug("CURRENT USER_ID BEGIN")
    # Rails.logger.debug(session.inspect)
    # Rails.logger.debug("CURRENT USER_ID END")
    begin
      if defined?(current_token) && current_token != nil
        user = current_token.user
        session[:user_id] = user.id
        @current_user = user
      elsif session[:simulated_id]
        @current_user ||= User.find(session[:simulated_id]) if session[:user_id]
      elsif session[:user_id]
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      elsif session[:digest]
        @current_user = User.new(:username => session[:digest].name, :email => session[:digest].email)
      end
    rescue ActiveRecord::RecordNotFound => e
      @current_user = nil
    end
  end



  #Kaushik Mahorker OAuth
  #Checks to see if request was made using OAuth
  #if so it sets current_user to the matching user based on the access_token parameter
  #else use standard login method
  def oauth_load
    if current_token != nil
      @current_user = current_token.user
      session[:platform] = Transaction::PLATFORMS[:mobile]
      define_session_permissions
    else
      login_required
    end
  end



  def logged_in?
    current_user.present?
  end



  def admin_required
    unless ['Admin', 'Global Admin'].include?(current_user.level)
      redirect_to errors_path
    end
  end



  def login_required
    unless logged_in?
      store_target_location
      redirect_to login_url, :alert => "You need to log in first to access this page."
    end
  end



  def redirect_to_target_or_default(default, *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end



  # TODO - where to redirect to?
  def restrict_module_access(module_name)
    access = current_user.module_access
    unless access.present? && access.include?(module_name)
      redirect_to root_url, :alert => "You are not authorized to access that module."
    end
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
  end



  private


  def store_target_location
    session[:return_to] = request.url
  end

  def store_location
    session[:return_to] = request.fullpath if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
  end

end
