class SessionsController < ApplicationController
  skip_before_filter :access_validation,:only=>[:destroy]
  after_filter :track_activity, :only => [:create]

  def new
    respond_to do |format|
      format.html do
        @categories = Category.all
      end
      format.json do
        render :json => { :error => 'Session expired. Log in again.' }.to_json, :status => 401
      end
    end
  end


  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      session[:mode] = ""
      session[:last_active] = Time.now
      define_session_permissions
      redirect_to_target_or_default(root_url)
    else
      flash.now[:danger] = "Invalid username or password."
      render :new
    end
  end


  def destroy
    respond_to do |format|
      format.html do
        if BaseConfig.airline[:enable_sso]
          redirect_to '/saml/logout'
        else
          session[:user_id] = nil
          session[:simulated_id] = nil
          session[:digest] = nil
          session[:last_active] = nil
          flash[:notice] = "You have been logged out."
          redirect_to new_session_path
        end
      end
      format.json do
        session[:user_id] = nil
        session[:simulated_id] = nil
        session[:digest] = nil
        session[:last_active] = nil
        render :json => { :error => 'Session expired. Log in again.' }.to_json, :status => 401
      end
    end
  end

  # gets the key from app and returns the associated config file
  def mobile_initialize
    key = params[:key].downcase.gsub('o','0')
    if BaseConfig::MOBILE_KEY_MAP.key? key
      config_file = BaseConfig::MOBILE_KEY_MAP[key]
      config_file[:key] = key
      render :json => config_file.to_json, :status => 200
      return
    else
      render :json => { error: 'Invalid Activation Key.' }.to_json, :status => 401
    end
  end

  # redirects to a deep link that the app will use to auto-fill the activation key and automatically attempt to activate
  def mobile_activate
    key = params[:key]
    redirect_to "prosafet://activate?key=#{key}"
  end


# -------------- BELOW ARE EVERYTHING FOR PROSAFET APP
  def get_user_json
    @user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      session[:mode] = "ASAP"
      @templates = user.templates
      stream = render_to_string(:templates=>"sessions/get_user_json.js.erb" )
      send_data(stream, :type=>"json", :disposition => "inline")
    end
  end




end
