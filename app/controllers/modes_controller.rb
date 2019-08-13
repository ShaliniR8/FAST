class ModesController < ApplicationController

  def switch
    session[:mode] = params[:mode]
    redirect_back_or_default(root_url)
  end

end
