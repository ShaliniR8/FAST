#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Users extend ActiveSupport::Concern

      def current_json
        # Get only the data that we need from the user
        mobile_user_info = current_user.as_json(only: [:id, :full_name, :email, :mobile_fetch_months])['user']

        # Get which modules the user has access to
        all_mobile_modules = ['ASAP', 'Safety Assurance']
        mobile_user_info[:mobile_module_access] = current_user.accessible_modules
          .select{ |module_name| all_mobile_modules.include? module_name }

        # Get and parse the user's notices
        mobile_user_info[:notices] = current_user.notices.as_json(only: [
          :id,
          :content,
        ]).map do |notice|
          notice = notice.first[1] # Drops { object: {contents} ... } to { {contents} ... }
          content = notice['content']
          extracted_uri = URI.extract(content, /http(s)?/)[0]
          
          if extracted_uri.present?
            parsed_content = extracted_uri.chop.split('/').reverse
            notice['owner_id'] = parsed_content[0]
            notice['type'] = parsed_content[1]
          end
          
          notice['content'] = content.gsub(/<a.*/, '').strip
          notice
        end

        render :json => mobile_user_info
      end

      def mobile_months
        current_user.update_attribute(:mobile_fetch_months, params[:months])
        render :json => { success: 'User\'s mobile fetch months have been updated.' }, :status => 200
      end

      ########################################################
      #--- Temporary methods for legacy app compatibility ---#
      ########################################################
      # ------------- BELOW ARE EVERYTHING ADDED FOR PROSAFET APP
        # following method added. BP Jul 14 2017
        # Added if statement for OAuth compatibiltiy KM Jul 17 2017
        def get_json
          @date = params[:date]
          if current_token != nil
            @user = current_token.user
          else
            @user = current_user
          end
          @submissions = current_user.submissions.where("created_at > ?",@date)
          stream = render_to_string(:template=>"users/get_json.js.erb" )
          send_data(stream, :type=>"json", :disposition => "inline")
        end

        #added by BP Aug 8 2017. Used to get all submissions with detailed fields from current user
        def submission_json
          if current_token != nil
            @user = current_token.user
          else
            @user = current_user
          end
          @submissions = Submission.find(:all, :conditions => [ "event_date > ?",'2017-8-11 12:00:00'])
          stream = render_to_string(:template=>"users/submission_json.js.erb" )
          send_data(stream, :type=>"json", :disposition => "inline")
        end


        def notices_json
          if current_token != nil
            @user = current_token.user
          else
            @user = current_user
          end
          @notices = @user.get_notices
          stream = render_to_string(:template=>"users/notices_json.js.erb" )
          send_data(stream, :type=>"json", :disposition => "inline")
        end
      ###############################
      #--- End Temporary Methods ---#
      ###############################

    end
  end
end