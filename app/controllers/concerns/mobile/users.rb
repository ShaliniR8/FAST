#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile
    module Users extend ActiveSupport::Concern

      def current_json
        # Get only the data that we need from the user
        mobile_user_info = current_user.as_json(only: [
          :id, :full_name, :email, :employee_number, :mobile_fetch_months,
        ])

        ##### Legacy, delete later
        mobile_user_info[:mobile_module_access] = ['ASAP']
        #####

        # Get which modules the user has access to
        mobile_user_info[:mobile_modules] = current_user.accessible_modules.reduce({}) do |module_access, module_name|
          submodules = []
          case module_name
          when 'ASAP'
            submodules.push('Submissions') if current_user.has_access('submissions', 'show', admin: CONFIG::GENERAL[:global_admin_default], strict: true) && 
                                              current_user.has_access('submissions', 'index', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
          when 'Safety Assurance'
            submodules.push('Audits') if current_user.has_access('audits', 'show', admin: CONFIG::GENERAL[:global_admin_default], strict: true) && 
                                         current_user.has_access('audits', 'index', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
            submodules.push('Investigations') if current_user.has_access('investigations', 'show', admin: CONFIG::GENERAL[:global_admin_default], strict: true) && 
                                              current_user.has_access('investigations', 'index', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
          end
          module_access[module_name] = submodules if submodules.length > 0 &&
            CONFIG.mobile_modules.include?(module_name)
          module_access
        end

        # Get and parse the user's notices
        mobile_user_info[:notices] = current_user.notices.as_json(only: [
          :id, :content,
        ]).map do |notice|
          content = notice['content']
          href_match = /href\s*=\s*(?:'|")([^'"]*)(?:'|")/.match(content)

          if href_match.present?
            parsed_content = href_match[1].split('/').reverse
            notice['owner_id'], notice['type'] = parsed_content
          end

          notice['content'] = content.gsub(/<a.*/, '').strip
          notice
        end

        permissions = { :submissions => [], :audits => [] }
        permissions[:submissions].push('new') if current_user.has_access('submissions', 'new', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
        permissions[:submissions].push('index') if current_user.has_access('submissions', 'index', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
        permissions[:submissions].push('show') if current_user.has_access('submissions', 'show', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
        mobile_user_info[:permissions] = permissions

        # change when configs are updated to v1.2
        mobile_user_info[:enable_dual_report] = CONFIG.sr::GENERAL[:enable_dual_report]

        if CONFIG::MOBILE_MODULES.include?('SMS')
          finding_json = Finding.get_meta_fields('form').as_json
          finding_json.each do |ffield|
            ffield.delete('num_cols') if ffield['num_cols'].present?
            ffield.delete('visible') if ffield['visible'].present?
            ffield['type'] = 'boolean' if ffield['type'] == 'boolean_box'
            ffield['options'] = eval(ffield['options']) if ffield['options'].present?
          end

          finding_title_json = Finding.get_meta_fields('show').as_json
          finding_title_json.each do |ffield|
            ffield.delete('num_cols') if ffield['num_cols'].present?
            ffield.delete('visible') if ffield['visible'].present?
            ffield.delete('type') if ffield['type'].present?
            ffield.delete('required') if ffield['required'].present?
            ffield.delete('options') if ffield['options'].present?
            ffield.delete('default') if ffield['default'].present?
            ffield.delete('on_newline') if ffield['on_newline'].present?
          end

          mobile_user_info[:finding_data] = finding_json
          mobile_user_info[:finding_metadata] = finding_title_json
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
