class ErrorsController < ApplicationController
  before_filter :oauth_load
  include Concerns::Mobile

  def index
    redirect_to :back, :notice => "You do not have the privileges required to perform this action. Please contact the admin for more details if you have any questions."
  end

  def debug_report
    respond_to do |format|
      format.html {}
      format.json { debug_report_as_json(params) }
    end
  end
end
