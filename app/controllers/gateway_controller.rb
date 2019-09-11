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

    redirect_to "/home"
    return

  end


end
