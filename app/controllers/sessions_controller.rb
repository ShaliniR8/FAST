class SessionsController < ApplicationController
  skip_before_filter :access_validation,:only=>[:destroy]


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
    puts "== crea#{session[:return_to]}"
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      session[:mode] = ""
      session[:last_active] = Time.now
      redirect_to_target_or_default(root_url)
    else
      flash.now[:danger] = "Invalid username or password."
      render :new
    end
  end


  def destroy
    session[:user_id] = nil
    session[:simulated_id] = nil
    session[:last_active] = nil
    respond_to do |format|
      format.html do
        flash[:notice] = "You have been logged out."
        redirect_to new_session_path
      end
      format.json do
        render :json => { :error => 'Session expired. Log in again.' }.to_json, :status => 401
      end
    end
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
