class ErrorsController < ApplicationController
  before_filter :oauth_load
  include Concerns::Mobile

  def index
    notice = "You do not have the privileges required to perform this action. Please contact the admin for more details if you have any questions."
    begin
      url = request.env['HTTP_REFERER'] rescue nil
      if url.present? && (url.include?('/new') || url.include('/edit'))
        redirect_to root_url
      else
        redirect_to :back, :notice => notice
      end
    rescue ActionController::RedirectBackError => e
      redirect_to root_url, :notice => notice
    end
  end

  def debug_report
    respond_to do |format|
      format.html {}
      format.json { debug_report_as_json(params) }
    end
  end
end
