#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Errors extend ActiveSupport::Concern

      def debug_report_as_json(params)
        ErrorMailer.mobile_debug_report(
          User.find(params[:user_id]),
          params[:device_info],
          params[:app_info],
          params[:message],
          params[:json_dump]
        )
        render json: { success: 'Debug Report Sent!' }, status: 200
      end

    end
  end
end