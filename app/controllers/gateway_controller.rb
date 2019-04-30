class GatewayController < ApplicationController
  before_filter :login_required, :except => []
  skip_before_filter :verify_authenticity_token

  def index
    if current_user.nil?
      # redirect_to :root
    end

    @page = "gateway"
    session[:id] = nil
    session[:newid] = nil

    @gateway_prefs = Object.const_get("GatewayPreferences")

    if(@gateway_prefs.getLayout[:custom])
      items =  current_user.module_access.split(',')
      @modules = @gateway_prefs.getModulePaths.select {|x| items.include?(x[:db_name])}
      @systems = @gateway_prefs.getSystemPaths.select {|x| items.include?(x[:db_name])}
    end

    # if(current_user.level == "Employee" && current_user.module_access.include?("maint"))
    #   redirect_to('/maint_work_requests/new')
    #   return
    # end

    # automatically redirect to audit module
    redirect_to "/home"
    return

  end


end
