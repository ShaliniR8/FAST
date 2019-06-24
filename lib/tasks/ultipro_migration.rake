namespace :ultipro do
  Rails.logger = Logger.new("log/ultipro_migration.log")
  @filepath = '/home/jiaming/dylan/Ultipro_POC.xml'
  #This is to compare the new file with the prior file
  @filepath_prior = '/home/jiaming/dylan/Ultipro_POC_prior.xml'
  @expand_output = false #Shows full account generation details
  @dry_run = false #Prevents the saving of data to the database

  #The following identifies what account type is associated with each employee-group
  @group_mapping = {
    'dispatch'    => 'Analyst',
    'fight-crew'  => 'Pilot',
    'ground'      => 'Ground',
    'maintenance' => 'Staff',
    'other'       => 'Staff'
  } #Cabin
  @tracked_privileges = [
    'Ground: Incident Submitter',
    'Ground: General Submitter',
    'Other: General Submitter',
    'Flight Crew: ASAP Submitter',
    'Flight Crew: Incident Submitter',
    'Flight Crew: Fatigue Submitter',
    'Dispatch: ASAP Submitter',
    'Dispatch: Incident Submitter',
    'Dispatch: Fatigue Submitter',
    'Maintenance: ASAP Submitter',
    'Maintenance: Incident Submitter',
    'Maitnenance: Fatigue Submitter',
    'Cabin: ASAP Submitter',
    'Cabin: Incident Submitter',
    'Cabin: Fatigue Submitter'
  ]

  ### Tasks

    task :update_userbase, [:filepath] => [:environment] do |t, args|
      Rails.logger.info '##############################'
      Rails.logger.info '### UPDATING USER DATABASE ###'
      Rails.logger.info '##############################'
      Rails.logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

      begin
        data_dump = File.read(@filepath).sub(/^\<\?.*\?\>$/, '')
      rescue
        Rails.logger.info "[ERROR] #{DateTime.now}: #{@filepath} could not be opened"
        next #Abort
      end

      if File.exist?(@filepath_prior) && compare_file(@filepath_prior, @filepath)
        Rails.logger.info "[INFO] Historical Data was identical- no update necessary"
        next #abort- nothing to update
      end
      begin
        Rails.logger.info "[INFO] #{DateTime.now}: Ultipro data updated- userbase being updated"
        @users = User.includes(:privileges, :roles).all.map{|u| [u.username, u]}.to_h
        @log_data = []
        Hash.from_xml(data_dump)['wbat_poc']['poc']
          .map{ |poc| [poc['user_name'], poc]}
          .to_h
          .each do |username, user_hash|
            @err_username = username #Used for error logging
            @err_user_hash = user_hash  #Used for error logging
            @log_entry = ""
            if @users.key?(username)
              user = @users[username]
            else
              user = generate_user user_hash
              next if user.nil?
              @log_entry << " Account Created"
            end
            update_privileges user, user_hash
            if !@log_entry.empty?
              @log_data << ("  [User] #{user.username}:" << @log_entry)
            end
          end
        IO.copy_stream(@filepath, @filepath_prior) #Update Historical File
        Rails.logger.info '###################################'
        Rails.logger.info '### ULTIPRO MIGRATION COMPLETED ###'
        Rails.logger.info '###################################'
      rescue
        Rails.logger.info '################################'
        Rails.logger.info '### ULTIPRO MIGRATION FAILED ###'
        Rails.logger.info '################################'
        Rails.logger.info "Failed on: #{@err_username}"
        Rails.logger.info "User's Ultipro Hash Data: #{@err_user_hash}"
        Rails.logger.info "Final log entry: #{@log_entry}"
      end
      Rails.logger.info "SERVER DATE+TIME OF CONCLUSION: #{DateTime.now.strftime("%F %R")}"
      Rails.logger.info 'SUMMARY OF EVENTS:'
      if @log_data.empty?
        Rails.logger.info 'No Userbase Changes'
      else
        @log_data.each do |log|
          Rails.logger.info log
        end
      end
    end #END update_userbase


    # Now obsolete method- was used for one-time importing of Ultipro data
      # WARNING- THERE MAY BE CONFILCTS WITH THE generate_user function and this!
    task :import_users, [:filepath] => [:environment] do |t, args|
      begin
        data_dump = File.read(@filepath)
      rescue
        puts "[ERROR] #{@filepath} could not be opened"
        next #Abort
      end

      @log_data = []
      @privilege_list = {}
      Privilege.all.each{ |priv| @privilege_list[priv[:name]] = priv.id }

      puts '### Generating Users ###'
      Hash.from_xml(data_dump)['wbat_poc']['poc'].each do |u|

        user = generate_user u

        begin
          user.save! if !@dry_run
        rescue
          @log_data << "[WARNING] User #{u['user_name']} data error- Skipped\n   #{u}"
          print 'x' if !@expand_output
          next
        end

        puts "User (#{u['employee_number']}): #{u['first_name']} #{u['last_name']}" if @expand_output
        puts " Email: #{u['email_address']}" if @expand_output

        begin
          puts 'Privileges:' if @expand_output
          privileges = u['access_privilege_list']['access_privilege']
          privileges = [privileges] if privileges.class == Hash
          privileges.each do |pr|
            if user.level.nil?
              user[:level] = map_account_level(pr['employee_group'])
              user.save!
            end
            priv =  "#{pr['employee_group'].titleize}: #{pr['access_group']}"
            generate_privilege priv unless @privilege_list.key? priv
            user.roles.new({privileges_id: @privilege_list[priv]}).save! if !@dry_run
            puts "  #{priv}" if @expand_output
          end
          print '.' if !@expand_output

        rescue
          if defined?(privileges)
            @log_data << "[NOTICE] Privileges not read for user #{user.full_name}:\n   -#{privileges || 'No privileges found'}"
          else
            @log_data << "[INFO] No privileges found for user #{user.full_name}"
          end
          print '*' if !@expand_output
        end
      end

      puts "\n### Task Notes ###"
      @log_data.each do |event|
        puts " #{event}"
      end
    end #END import_users


 ### Helper Methods

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
          password: 'ObfUsCaTeD_pAsSwOrD',
          employee_number: user_hash['employee_number'],
          level: map_account_level(user_hash['employee_group'])
        })
        user[:sso_id] = user_hash['email_address']
        user.save! if !@dry_run
        return user
      rescue
        @log_entry << "   Account Creation Failed!\n    User: #{user_hash['user_name']}\n    Ultipro Data: #{user_hash}"
        return nil
      end
    end


    def update_privileges user, user_hash
      user_privileges = user.privileges.map{|priv| priv[:name]}
      @privilege_list ||= Privilege.all.map{ |priv| [priv[:name], priv.id] }.to_h
      privileges = user_hash['access_privilege_list']['access_privilege'] rescue []
      privileges = [privileges] if privileges.class == Hash
      privileges = privileges.map{ |priv| "#{priv['employee_group'].titleize}: #{priv['access_group']}" }

      privileges.each do |priv| #First check user has all privileges expected
        if user.level.nil?
          user[:level] = map_account_level(pr['employee_group'])
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


    def map_account_level employee_group
      if @group_mapping.key? employee_group
        @group_mapping[employee_group]
      else
        'Staff'
      end
    end


end #END MODULE
