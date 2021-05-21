require 'roo'
namespace :update_rjet do

  logger = Logger.new("log/update_users.log")
  logger.info '##############################'
  logger.info '### UPDATING USER DATABASE ###'
  logger.info '##############################'
  logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  filename = "RepublicUserAccountsMaster"
  filepath = './lib/tasks/' + filename
  filetype = ".csv"

  error_string = ""

  task :update_userbase => :environment do
    assign_configs_
    fetch_file_
    AIRLINE_CODE = "rjet_"

    puts "Importing user account info..."

    #opening file
    begin
        workbook = Roo::Spreadsheet.open(filepath + filetype);

    rescue
        logger.info "[ERROR] #{DateTime.now}: #{filepath + filename + filetype} could not be opened"
        next #Abort
    end
    if File.exist?(filepath +  filetype) && compare_file(filepath + "_prior" + filetype, filepath + filetype)
        p "[INFO] Historical Data was identical- no update necessary"
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

        (first_row..workbook.last_row).each do |index|

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
                msg = "Missing first name - Failed to create/update user: " + row[FIRSTNAME_COL].to_s + " " + row[LASTNAME_COL].to_s + " (row: " + counter.to_s  + ")"
                error_string += msg + "\n"
                logger.info msg
                errors += 1
            elsif row[LASTNAME_COL].nil? || row[LASTNAME_COL].strip.empty?
                msg = "Missing last name - Failed to create/update user: " + row[FIRSTNAME_COL].to_s + " " + row[LASTNAME_COL].to_s + " (row: " + counter.to_s  + ")"
                error_string += msg + "\n"
                logger.info msg
                errors += 1  
            end

            #catches duplicate usernames
            if my_users[username]
                msg = "Duplicate entry - Failed to create/update user - A user with this username was already created or updated: " + row[FIRSTNAME_COL].to_s + " " + row[LASTNAME_COL].to_s + " (row: " + counter.to_s  + ")"
                error_string += msg + "\n"
                logger.info msg
                errors += 1
            end

            #catches users who don't have usernames
            if  username.nil? || username_len == 0
                msg = "No username - Failed to create/update user " + row[FIRSTNAME_COL].to_s + " " + row[LASTNAME_COL].to_s + " (row: " + counter.to_s  + ")"
                error_string += msg + "\n"
                logger.info msg
                errors += 1
            end

            user = User.where(username: row[USERNAME_COL].to_s).first
            #user exists and is not external -> update
            if row[FIRSTNAME_COL].present? && row[LASTNAME_COL].present? && my_users[username].nil? && username_len > 0 && user && user.level != 'External' && user.ignore_updates != true
                begin 
                    user.update_attributes!(
                        # username:           row[USERNAME_COL].to_s,
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
                        puts current_privileges
                        privileges.each do |privilege|
                            if Privilege.find_by_name(privilege) && current_privileges.exclude?(privilege)
                                begin
                                    Role.new(
                                            users_id: user.id,
                                            privileges_id: Privilege.find_by_name(privilege).id
                                    ).save!
                                rescue => e
                                    msg = "Failed to create user privilege #{privilege} for " + row[FIRSTNAME_COL].to_s + " " +  row[LASTNAME_COL].to_s + " " +  e.message + "(row: " + counter.to_s  + ")"
                                    error_string += msg + "\n"
                                    logger.info msg
            
                                end 
                            else
                                msg = "Failed to create user privilege #{privilege} for " + row[FIRSTNAME_COL].to_s + " " +  row[LASTNAME_COL].to_s + " " +  "(row: " + counter.to_s  + ")"
                                error_string += msg + "\n"
                                logger.info msg
                            end
                        end
                    
                    #add to hash map
                    my_users[username] = true
                    users_in_list << user
                    updated_users_list << user
                    updated_users += 1 
                rescue => e
                    msg = 'Failed to update user ' + row[FIRSTNAME_COL].to_s + " " +  row[LASTNAME_COL].to_s + "(row: " + counter.to_s  + ")"
                    error_string += msg + "\n"
                    logger.info msg
                    logger.info e.message
                    error_string += e.message + "\n" 
                    errors += 1              
                end 

            #user does not exist -> create new user
            elsif row[FIRSTNAME_COL].present? && row[LASTNAME_COL].present? && user.nil? && username_len > 0
                #add user to array
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
                        puts privilege
                        if Privilege.find_by_name(privilege)
                            begin
                                Role.new(
                                        users_id: user.id,
                                        privileges_id: Privilege.find_by_name(privilege).id
                                ).save!
                            rescue => e
                                msg = "Failed to create user privilege #{privilege} for " + row[FIRSTNAME_COL].to_s + " " +  row[LASTNAME_COL].to_s + " " +  e.message + "(row: " + counter.to_s  + ")"
                                error_string += msg + "\n"
                                logger.info msg
                            end
                        else
                            msg = "Failed to create user privilege #{privilege} for " + row[FIRSTNAME_COL].to_s + " " +  row[LASTNAME_COL].to_s + " " +  "(row: " + counter.to_s  + ")"
                            error_string += msg + "\n"
                            logger.info msg
                        end 
                    end
                 
                  #add to hash map
                  my_users[username] = true
                  users_in_list << user
                  created_users_list << user
                  added_users += 1
                rescue => e
                    msg = "Failed to create user " + row[FIRSTNAME_COL].to_s + " " + row[LASTNAME_COL].to_s + "(row: " + counter.to_s  + ")" 
                    error_string += msg + "\n"
                    logger.info msg
                    logger.info e.message
                    error_string += e.message + "\n"
                    errors += 1
                end           
            end
            end
        end 
        
        #if no errors occurred, Update Historical File and disable users
        IO.copy_stream("lib/tasks/#{filename}.csv", "lib/tasks/#{filename}_prior.csv") #Update Historical File

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

        logger.info "\nDeleted/Disabled Users: "
        logger.info diff.map{|u| u.id}.to_s
        logger.info "\nCreated Users: "
        logger.info created_users_list.map{|u| u.id}.to_s
        logger.info "\nUpdated Users: "
        logger.info updated_users_list.map{|u| u.id}.to_s
        logger.info '###################################'
        logger.info "Number of active (visible) users before update: " + active_users_before_update.length().to_s 
        logger.info "Created Users: " + added_users.to_s
        logger.info "Updated Users: " + updated_users.to_s
        logger.info "Unable to create/update: " + errors.to_s
        logger.info "Deleted Users: " + deleted_users.to_s
        logger.info "Number of active (visible) users after update: " + active_users_after_update.length().to_s 
        logger.info '###################################'
        logger.info '### UPDATING USERBASE COMPLETED ###'
        logger.info '###################################'


        #if errors occurred, send email with error-descriptions 
        if error_string.length() > 0
            #error_string += "\n Number of active (visible) users before update:  " +  active_users_before_update.length().to_s 
            error_string += "\n Created Users: " + added_users.to_s 
            error_string += "\n Updated Users: " + updated_users.to_s 
            error_string += "\nUnable to create/update: " + errors.to_s
            error_string += "\n Deleted Users: " + deleted_users.to_s 
            error_string += "\n Number of active (visible) users after update: " + active_users_after_update.length().to_s 
            NotifyMailer.notify_user_errors("Some errors occurred while executing the RJET daily user onboarding rake task", error_string)
        end
    end

    def fetch_file_
        `cp #{@upload_path} ./lib/tasks/RepublicUserAccountsMaster.csv`
    end
    
    def assign_configs_
        configs = Object.const_get("#{YAML.load_file("#{::Rails.root}/config/airline_code.yml")}Config")::RJET_DATA
        @upload_path = configs[:upload_path]
    end
end


