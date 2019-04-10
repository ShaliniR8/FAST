class OauthClientsController < ApplicationController
  before_filter :login_required
  before_filter :get_client_application, :only => [:show, :edit, :update, :destroy]

  

  def index
    @client_applications = current_user.client_applications
    @tokens = current_user.tokens.find :all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null'
    p @tokens
  end

  def new
    @client_application = ClientApplication.new
  end

  def create
    @client_application = current_user.client_applications.build(params[:client_application])
    if @client_application.save
      flash[:notice] = "Registered the information successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "new"
    end
  end

  def show
  end

  def edit
  end

  def update
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = "Updated the client information successfully"
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application.destroy
    flash[:notice] = "Destroyed the client application registration"
    redirect_to :action => "index"
  end

  def authenticate_user(username,password)
    user = User.authenticate(params[:login], params[:password])
    if user
      #Rails.logger.info user.inspect
      session[:user_id] = user.id
      session[:mode] = "ASAP"
      #Rails.logger.info session.inspect
      #flash[:notice] = "Logged in successfully."
      #if current_user.level == "Employee"
      #  redirect_to(work_requests_path)
      #else
        redirect_to_target_or_default(root_url)
      #end
    else
      #Rails.logger.info 'not authenticated'

      flash.now[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end

  private
  def get_client_application
    unless @client_application = current_user.client_applications.find(params[:id])
      flash.now[:error] = "Wrong application id"
      raise ActiveRecord::RecordNotFound
    end
  end
end