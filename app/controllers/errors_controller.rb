class ErrorsController < ApplicationController
  before_filter :oauth_load
  include Concerns::Mobile
  
  def debug_report
    respond_to do |format|
      format.html {}
      format.json { debug_report_as_json(params) }
    end
  end
end
