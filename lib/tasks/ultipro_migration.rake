namespace :ultipro do
  require 'securerandom'
  logger = Logger.new("log/ultipro_migration.log")


  ### Tasks

    task :update_userbase => [:environment] do |t, args|
      begin

        logger.info '##############################'
        logger.info '### UPDATING USER DATABASE ###'
        logger.info '##############################'
        logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

        assign_configs
        fetch_file
        @sso_identifier_tag = CONFIG::ULTIPRO_DATA[:sso_identifier_tag]
        @sso_identifier_attribute = CONFIG::ULTIPRO_DATA[:sso_identifier_attribute]
        begin
          data_dump = case AIRLINE_CODE
            when 'SCX'
              File.read('lib/tasks/ultipro_data.xml').sub(/^\<\?.*\?\>$/, '').sub(/\<\/xml\>/, '')
            when 'FFT'
              File.read('lib/tasks/ultipro_data.xml').sub(/\<\/xml\>/, '')
          end
        rescue
          logger.info "[ERROR] #{DateTime.now}: #{'lib/tasks/ultipro_data.xml'} could not be opened"
          next #Abort
        end

        if File.exist?('lib/tasks/ultipro_data_prior.xml') && compare_file('lib/tasks/ultipro_data_prior.xml', 'lib/tasks/ultipro_data.xml')
          logger.info "[INFO] Historical Data was identical- no update necessary"
          next #abort- nothing to update
        end
        begin
          logger.info "[INFO] #{DateTime.now}: Ultipro data updated- userbase being updated"
          @users = User.includes(:privileges, :roles).all.map{|u| [u.username.downcase, u]}.to_h
          @users_sso_map = User.includes(:privileges, :roles).all.map{|u| [u.send(@sso_identifier_attribute), u]}.to_h
          @users_sso_map = @users_sso_map.select{|key, val| key.present?}.map{|key, val| [key.downcase, val]}.to_h
          @log_data = []
          User.transaction do
            Hash.from_xml(data_dump)['wbat_poc']['poc']
              .map{ |poc| [poc['user_name'], poc]}
              .to_h
              .each do |username, user_hash|
                @err_username = username #Used for error logging
                @err_user_hash = user_hash  #Used for error logging
                @log_entry = ""
                sso_identifier = user_hash[@sso_identifier_tag]
                if @users.key?(username.downcase)
                  user = @users[username.downcase]
                elsif @users.key?(username)
                  user = @users[username]
                elsif @users_sso_map.key?(sso_identifier.downcase)
                  user = @users_sso_map[sso_identifier.downcase]
                elsif @users_sso_map.key?(sso_identifier)
                  user = @users_sso_map[sso_identifier]
                else
                  user = generate_user user_hash
                  @log_entry << " Account Created" if user.present?
                end
                update_account_detail user, user_hash
                update_privileges user, user_hash
                if !@log_entry.empty?
                  if user.present?
                    @log_data << ("  [User] #{user.username}:" << @log_entry)
                  else
                    @log_data << ("  "<<@log_entry)
                  end
                end
              end
          end
          IO.copy_stream('lib/tasks/ultipro_data.xml', 'lib/tasks/ultipro_data_prior.xml') #Update Historical File
          logger.info '###################################'
          logger.info '### ULTIPRO MIGRATION COMPLETED ###'
          logger.info '###################################'
        rescue
          logger.info '################################'
          logger.info '### ULTIPRO MIGRATION FAILED ###'
          logger.info '################################'
          logger.info "Failed on: #{@err_username}"
          logger.info "User's Ultipro Hash Data: #{@err_user_hash}"
          logger.info "Final log entry: #{@log_entry}"
        end
        logger.info "SERVER DATE+TIME OF CONCLUSION: #{DateTime.now.strftime("%F %R")}"
        logger.info 'SUMMARY OF EVENTS:'
        if @log_data.empty?
          logger.info 'No Userbase Changes'
        else
          @log_data.each do |log|
            logger.info log
          end
        end
      rescue => error
        location = 'ultipro:update_userbase'
        subject = "Rake Task Error Encountered In #{location.upcase}"
        error_message = error.message
        NotifyMailer.notify_rake_errors(subject, error_message, location)
      end
    end #END update_userbase


 ### Helper Methods

    def assign_configs
      configs = Object.const_get("#{YAML.load_file("#{::Rails.root}/config/airline_code.yml")}Config")::ULTIPRO_DATA
      @upload_path = configs[:upload_path]
      @expand_output =  configs[:expand_output]
      @dry_run = configs[:dry_run]
      @group_mapping = configs[:group_mapping]
      @tracked_privileges = configs[:tracked_privileges]
    end

    def generate_privilege title
      priv = Privilege.new({
        name: title,
        description: '',
        example: ''
      })
      if @dry_run || priv.save!
        @privilege_list[title] = priv.id
        @log_data << "[INFO] Generated New Privilege: #{title}"
      end
    end


    def generate_user user_hash

      begin
        user = User.new({
          username: user_hash['user_name'],
          email: user_hash['email_address'],
          full_name: "#{user_hash['first_name']} #{user_hash['last_name']}",
          first_name: user_hash['first_name'],
          last_name: user_hash['last_name'],
          password: SecureRandom.urlsafe_base64(20),
          @sso_identifier_attribute.to_sym => user_hash[@sso_identifier_tag],
          level: map_account_level(user_hash['employee_group'])
        })
        user.sso_id = user_hash[@sso_identifier_tag]

        user.save! if !@dry_run
        return user
      rescue => error
        @log_entry << "   Account Creation Failed!\n    User: #{user_hash['user_name']}\n    Ultipro Data: #{user_hash}\n    Error Message: #{error.message}"
        return nil
      end
    end


    def update_privileges user, user_hash
      return nil if user.nil?
      user_privileges = user.privileges.map{|priv| priv[:name]}
      @privilege_list ||= Privilege.all.map{ |priv| [priv[:name], priv.id] }.to_h
      privileges = user_hash['access_privilege_list']['access_privilege'] rescue []
      privileges = [privileges] if privileges.class == Hash
      privileges = privileges.map{ |priv| "#{priv['employee_group'].titleize}: #{priv['access_group']}" }

      privileges.each do |priv| #First check user has all privileges expected
        if user.level.nil?
          user[:level] = map_account_level(priv['employee_group'])
          user.save!
        end
        generate_privilege priv unless @privilege_list.key?(priv) #Ensure privilege exists

        unless user_privileges.include? priv
          user.roles.new({privileges_id: @privilege_list[priv]}).save! if !@dry_run
          @log_entry << "\n    Added- #{priv}"
        end
      end
      user_privileges.each do |priv| #Next check if user has any privs that they shouldn't
        if @tracked_privileges.include?(priv) && !privileges.include?(priv)
          user.roles.where({privileges_id: @privilege_list[priv]}).destroy_all if !@dry_run
          @log_entry << "\n    Removed- #{priv}"
        end
      end
    end


    def update_account_detail user, user_hash
      return nil if user.nil?
      begin
        if user.sso_id != user_hash[@sso_identifier_tag]
          @log_entry << "\n     Update SSO ID: #{user.sso_id} to #{user_hash[@sso_identifier_tag]}"
          user.sso_id = user_hash[@sso_identifier_tag]
        end
        if user.username != user_hash['user_name']
          @log_entry << "\n     Update Username: #{user.username} => #{user_hash['user_name']}"
          user.username = user_hash['user_name']
        end
        if user.email != user_hash['email_address']
          @log_entry << "\n     Update Email: #{user.email} => #{user_hash['email_address']}"
          user.email = user_hash['email_address']
        end
        if user.employee_number != user_hash['employee_number']
          @log_entry << "\n     Update Employee #: #{user.employee_number} => #{user_hash['employee_number']}"
          user.employee_number = user_hash['employee_number']
        end
        updated_full_name = false
        if user_hash['first_name'].present? && user.first_name != user_hash['first_name']
          @log_entry << "\n     Update First Name: #{user.first_name} => #{user_hash['first_name']}"
          user.first_name = user_hash['first_name']
          updated_full_name = true
        end
        if  user_hash['last_name'].present? && user.last_name != user_hash['last_name']
          @log_entry << "\n     Update Last Name: #{user.last_name} => #{user_hash['last_name']}"
          user.last_name = user_hash['last_name']
          updated_full_name = true
        end
        if user_hash['first_name'].present? && user_hash['last_name'].present? && updated_full_name
          full_name = user_hash['first_name'] +' '+ user_hash['last_name']
          @log_entry << "\n     Update Full Name: #{user.full_name} => #{full_name}"
          user.full_name = full_name
        end
        user.save!
      rescue => error
        @log_entry << "   Account Update Failed!\n    User: #{user_hash['user_name']}\n    Ultipro Data: #{user_hash}\n    Error Message: #{error.message}"
      end
    end



    def map_account_level employee_group
      if @group_mapping.key? employee_group
        @group_mapping[employee_group]
      else
        'Staff'
      end
    end

    def fetch_file
      `cp #{@upload_path} lib/tasks/ultipro_data.xml`
    end


end #END MODULE
