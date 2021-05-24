require 'roo'
namespace :csv_user_import do

  logger = Logger.new("log/update_users.log")
  logger.info '##############################'
  logger.info '### UPDATING USER DATABASE ###'
  logger.info '##############################'
  logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  task :update_userbase => :environment do
    csv_config = assign_configs

    email_body = ""
    log_body = ""
    email_subject = "Your Daily #{csv_config[:name]} User Import Was Successfully Executed"
    email_subject_error = "Some Errors Occurred While Executing The #{csv_config[:name]} Daily User Onboarding Rake Task"

    #opening file
    begin
      workbook = Roo::Spreadsheet.open(csv_config[:destination_file_path]);

    rescue
      logger.info "[ERROR] #{DateTime.now}: #{csv_config[:destination_file_path]} could not be opened"
      email_body += "\n[ERROR] #{DateTime.now}: #{csv_config[:destination_file_path]} could not be opened"
      NotifyMailer.notify_user_errors(email_subject_error, email_body)
      next #Abort
    end

    if File.exist?(csv_config[:destination_file_path]) && compare_file(csv_config[:destination_file_path], csv_config[:destination_file_path_prev_file])
      p "[INFO] Historical Data was identical- no update necessary"
      email_body += "\n[INFO] Historical Data was identical- no update necessary"
      NotifyMailer.notify_user_errors(email_subject, email_body)
      logger.info "[INFO] Historical Data was identical- no update necessary"
      next #abort- nothing to update
    end

    begin

      USERNAME_COL = 0
      ACCOUNT_PRIVILEGE_COL = 1
      EMPLOYEENUMBER_COL = 2
      FIRSTNAME_COL = 3
      LASTNAME_COL = 4
      EMAIL_COL = 5
      JOBTITLE_COL = 6
      ACCOUNTTYPE_COL = 7
      ADDRESS_COL = 8
      CITY_COL = 9 
      STATE_COL = 10
      ZIPCODE_COL = 11
      MOBILENUMBER_COL = 12
      WORKNUMBER_COL = 13

      users_in_list = []
      created_users_list = []
      updated_users_list = []


      #errors
      no_username_error = []
      no_first_name_error = []
      no_last_name_error = []
      unknown_privilege_error = []
      duplicate_username_error = []
      generic_update_user_error = []
      generic_create_user_error = []
      generic_create_privilege_error = []



      #hash map containing usernames of all updated or created users to catch duplicates
      my_users = {}
      count = 0
      errors = 0
      first_row = 2

      added_users = 0
      deleted_users = 0
      updated_users = 0
      counter = 1

      #number of visible users before update
      active_users_before_update = User.all.select{|m| m.disable != true}
      disabled_users_before_update = User.all.select{|m| m.disable == true}

      (first_row..workbook.last_row).each do |index|

      do_not_update_or_create = false
      counter += 1
      row = workbook.row(index)
      username = row[USERNAME_COL]

      if username
        username = username.gsub(/\s+/, "").to_s.downcase
      end

      username_len = username.nil? ? 0 : username.length()

      p 'username: ' + row[USERNAME_COL].to_s
      p "row: " + counter.to_s

      #create array of privileges and remove whitespace
      privileges = row[ACCOUNT_PRIVILEGE_COL].split(";")
      privileges = privileges.collect{|p| p ? p.strip : p}

      #catches missing first- and/or last name
      if row[FIRSTNAME_COL].nil? || row[FIRSTNAME_COL].strip.empty?
        errors += 1
        no_first_name_error << counter.to_s 
        do_not_update_or_create = true
      elsif row[LASTNAME_COL].nil? || row[LASTNAME_COL].strip.empty?
        errors += 1  
        no_last_name_error << counter.to_s 
        do_not_update_or_create = true
      end

      #catches duplicate usernames
      if my_users[username]
        errors += 1
        duplicate_username_error << counter.to_s 
        do_not_update_or_create = true
      end

      #catches users who don't have usernames
      if  username.nil? || username_len == 0
        errors += 1
        no_username_error << counter.to_s 
        do_not_update_or_create = true
      end

      user = User.where(username: row[USERNAME_COL].to_s).first
      #user exists and is not external -> update
      if do_not_update_or_create == false && user && user.level != 'External' && user.ignore_updates != true
        begin 
          user.update_attributes!(
            level:              row[ACCOUNTTYPE_COL],
            email:              row[EMAIL_COL],
            first_name:         row[FIRSTNAME_COL],
            last_name:          row[LASTNAME_COL],
            full_name:          row[FIRSTNAME_COL] + ' ' + row[LASTNAME_COL],
            employee_number:    row[EMPLOYEENUMBER_COL],
            password:           '1rDte@p9q657UtfH&4wQ!',
            sso_id:             row[EMAIL_COL],
            job_title:          row[JOBTITLE_COL],
            address:            row[ADDRESS_COL],
            city:               row[CITY_COL],
            state:              row[STATE_COL], 
            zip_code:           row[ZIPCODE_COL], 
            mobile_number:      row[MOBILENUMBER_COL],
            work_phone_number:  row[WORKNUMBER_COL],
            disable:            false
            )

          #check if privilege exists and/or is alreay assigned to user
          current_privileges =  user.privileges.map{|p| p.name}
          privileges.each do |privilege|
            if Privilege.find_by_name(privilege) 
              if current_privileges.exclude?(privilege)
                begin
                  Role.new(
                    users_id: user.id,
                    privileges_id: Privilege.find_by_name(privilege).id
                  ).save!
                rescue => e
                  generic_create_privilege_error << counter.to_s 
                end 
              end
            else
              unknown_privilege_error << counter.to_s  
            end
          end

          #add to hash map
          my_users[username] = true
          users_in_list << user
          updated_users_list << user
          updated_users += 1 
        rescue => e
          errors += 1
          generic_update_user_error << counter.to_s              
        end 

      #user does not exist -> create new user
      elsif do_not_update_or_create == false && user.nil? && username_len > 0
        begin
          user = User.new(
            username:           row[USERNAME_COL].to_s,
            level:              row[ACCOUNTTYPE_COL],
            email:              row[EMAIL_COL],
            first_name:         row[FIRSTNAME_COL],
            last_name:          row[LASTNAME_COL],
            full_name:          row[FIRSTNAME_COL] + ' ' + row[LASTNAME_COL],
            employee_number:    row[EMPLOYEENUMBER_COL],
            password:           '1rDte@p9q657UtfH&4wQ!',
            sso_id:             row[EMAIL_COL],
            job_title:          row[JOBTITLE_COL],
            address:            row[ADDRESS_COL],
            city:               row[CITY_COL],
            state:              row[STATE_COL], 
            zip_code:           row[ZIPCODE_COL], 
            mobile_number:      row[MOBILENUMBER_COL],
            work_phone_number:  row[WORKNUMBER_COL],
            disable:            false

            )
          user.save!                    

          #check if privilege exists and/or is alreay assigned to user
          privileges.each do |privilege|
            if Privilege.find_by_name(privilege)
              begin
                Role.new(
                  users_id: user.id,
                  privileges_id: Privilege.find_by_name(privilege).id
                ).save!
              rescue => e
                generic_create_privilege_error << counter.to_s 
              end
            else
                unknown_privilege_error << counter.to_s 
            end 
          end
          #add to hash map
          my_users[username] = true
          users_in_list << user
          created_users_list << user
          added_users += 1
        rescue => e
          errors += 1
          generic_create_user_error << counter.to_s
        end           
      end
    end
  end 

  #if no errors occurred, Update Historical File and disable users
  IO.copy_stream(csv_config[:destination_file_path], csv_config[:destination_file_path_prev_file])


  #get all users that will be disabled
  all_users_db = User.all.select{|m| m.disable != true}
  all_users = User.all.select{|m| m.ignore_updates == false and  m.level != 'External' and m.disable != true}
  diff = all_users - users_in_list

  #disable users that were not in CSV file
  deleted_users = diff.length()

  diff.each do |u|
    u.disable = true
    u.save
  end

  #all active (visible) users after update
  active_users_after_update = User.all.select{|m| m.disable != true}
  disabled_users_after_update = User.all.select{|m| m.disable == true}

  email_body += "\nBEFORE UPDATE:\n"
  email_body += "\nTotal Active Users: " + active_users_before_update.length().to_s 
  email_body += "\nTotal Disabled Users: " + disabled_users_before_update.length().to_s 

  email_body += "\n\nAFTER UPDATE:\n"
  email_body += "\nTotal Active Users: " + active_users_after_update.length().to_s 
  email_body += "\nTotal Disabled Users: " + disabled_users_after_update.length().to_s 

  email_body += "\n\nUPDATE:\n"
  email_body += "\nCreated Users: " + added_users.to_s 
  email_body += "\nUpdated Users: " + updated_users.to_s 
  email_body += "\nDisabled Users: " + deleted_users.to_s 

  current_errors = no_username_error.length() + no_first_name_error.length() + no_last_name_error.length() + unknown_privilege_error.length() + generic_create_privilege_error.length() + generic_create_user_error.length() + generic_update_user_error.length()
  
  #errors were found
  if current_errors > 0
    email_subject = email_subject_error
    log_body += "\n\nUNABLE TO CREATE OR UPDATE:\n"
    
    if no_username_error.length() > 0
      p "No first name was provided for: #{no_username_error.map{|r| r}.to_s}"
      log_body += "\nNo username was provided for user(s) in row(s): #{no_username_error.map{|r| r}.to_s}"
    end

    if no_first_name_error.length() > 0
      p "No first name was provided for: " + no_first_name_error.map{|r| r}.to_s
      log_body += "\nNo first name was provided for user(s) in row(s): #{no_first_name_error.map{|r| r}.to_s}" 
    end

    if no_last_name_error.length() > 0
      p "No last name was provided for: " + no_last_name_error.map{|r| r}.to_s
      log_body += "\nNo last name was provided for user(s) in row(s): #{no_last_name_error.map{|r| r}.to_s}"
    end

    if unknown_privilege_error.length() > 0
      p "Unknown user privilege: " +  unknown_privilege_error.map{|r| r}.to_s
      log_body += "\nUnknown user privilege for user(s) in row(s): #{unknown_privilege_error.map{|r| r}.to_s}"  
    end

    if  duplicate_username_error.length() > 0
      p "Duplicate username: " +  duplicate_username_error.map{|r| r}.to_s
      log_body += "\nDuplicate username for user(s) in row(s): #{duplicate_username_error.map{|r| r}.to_s}"  
    end

    if generic_create_privilege_error.length() > 0
      p "Generic privilege error: " +  generic_privilege_error.map{|r| r}.to_s
      log_body += "\nUnknown user privilege for user(s) in row(s): #{generic_create_privilege_error.map{|r| r}.to_s}"  
    end

    if generic_create_user_error.length() > 0
      p "Generic create user error: " +  generic_create_user_error.map{|r| r}.to_s
      log_body += "\nGeneric Create User error for user(s) in row(s): #{generic_create_user_error.map{|r| r}.to_s}" 
    end

    if generic_update_user_error.length() > 0
      p "Generic update user error: " +  generic_update_user_error.map{|r| r}.to_s
      log_body += "\nGeneric Update User error for user(s) in row(s): #{generic_update_user_error.map{|r| r}.to_s}" 
    end
  end

  logger.info email_body + log_body
  logger.info '###################################'
  logger.info '### UPDATING USERBASE COMPLETED ###'
  logger.info '###################################'

  #send email
  NotifyMailer.notify_user_errors(email_subject, email_body + log_body)
  end

  def assign_configs
    configs = CONFIG::CSV_FILE_USER_IMPORT
    @target_file_path = configs[:target_file_path]
    @destination_file_path = configs[:destination_file_path]
    @destination_file_path_prev_file = configs[:destination_file_path_prev_file]

    {
    name: configs[:name],
    target_file_path: configs[:target_file_path],
    destination_file_path: configs[:destination_file_path],
    destination_file_path_prev_file: configs[:destination_file_path_prev_file]
    }
  end
end


