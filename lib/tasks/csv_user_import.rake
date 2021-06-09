namespace :csv_user_import do
  require 'roo'

  USERNAME_COL          = 0
  ACCOUNT_PRIVILEGE_COL = 1
  EMPLOYEENUMBER_COL    = 2
  FIRSTNAME_COL         = 3
  LASTNAME_COL          = 4
  EMAIL_COL             = 5
  JOBTITLE_COL          = 6
  ACCOUNTTYPE_COL       = 7
  ADDRESS_COL           = 8
  CITY_COL              = 9
  STATE_COL             = 10
  ZIPCODE_COL           = 11
  MOBILENUMBER_COL      = 12
  WORKNUMBER_COL        = 13
  COLUMN_NUMBER         = 14

  task :update_userbase => :environment do
    assign_config

    begin_log
    exit unless fetch_csv_file
    exit unless valid_csv_file?
    exit unless open_csv_file
    upload_users
    update_historical_file
    disable_users # who are not on the csv files
    send_user_import_result
    end_log
  end #END update_userbase


  def begin_log
    @logger.info '##############################'
    @logger.info '### UPDATING USER DATABASE ###'
    @logger.info '##############################'
    @logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"
  end


  def end_log
    @logger.info '###################################'
    @logger.info '### UPDATING USERBASE COMPLETED ###'
    @logger.info "###################################\n\n"
  end


  def log_and_notify_user(email_subject:, msg:)
    puts msg
    @logger.info msg
    email_body = msg
    NotifyMailer.notify_user_import_result(email_subject, email_body)
  end


  def assign_config
    @filename              = CONFIG::CSV_FILE_USER_IMPORT[:filename]
    @prev_filename         = CONFIG::CSV_FILE_USER_IMPORT[:prev_filename]
    @destination_file_path = CONFIG::CSV_FILE_USER_IMPORT[:destination_file_path]
    @target_file_path      = CONFIG::CSV_FILE_USER_IMPORT[:target_file_path]
    @sso_id                = CONFIG::CSV_FILE_USER_IMPORT[:sso_id]

    @target           = "#{@target_file_path}/#{@filename}"
    @destination      = "#{@destination_file_path}/#{@filename}"
    @prev_destination = "#{@destination_file_path}/#{@prev_filename}"

    @logger = Logger.new("log/csv_user_import.log")
    @email_subject       = "Your Daily #{AIRLINE_CODE} User Import Was Successfully Executed"
    @email_subject_error = "Some Errors Occurred While Executing. The #{AIRLINE_CODE} Daily User Onboarding Task"
  end


  def fetch_csv_file
    unless system("cp #{@target} #{@destination}")
      error_msg = "[ERROR] #{DateTime.now}: #{@target} could not be fetched. Please check the file name and the path.\n"
      log_and_notify_user(email_subject: @email_subject_error, msg: error_msg)
      end_log
      return false
    end
    true
  end


  def valid_csv_file?
    if File.exist?(@destination) &&
       compare_file(@destination, @prev_destination)
    then
      error_msg = "[INFO] Historical data was identical - no update necessary\n"
      log_and_notify_user(email_subject: @email_subject, msg: error_msg)
      end_log
      return false
    end
    true
  end


  def open_csv_file
    begin
      @table = CSV.parse(File.read(@destination), headers: false)
      @workbook = Roo::Spreadsheet.open(@destination);
    rescue
      error_msg = "[ERROR] #{DateTime.now}: #{@destination} could not be opened\n"
      log_and_notify_user(email_subject: @email_subject_error, msg: error_msg)
      end_log
      return false
    end
    true
  end


  def sso_id_column
    case @sso_id
    when :email
      EMAIL_COL
    when :employee_number
      EMPLOYEENUMBER_COL
    end

  end


  def sso_id_col_in(row)
    case @sso_id
    when :email
      row[EMAIL_COL].downcase rescue nil
    when :employee_number
      row[EMPLOYEENUMBER_COL]
    else
      ''
    end
  end


  def get_user_params(row)
    {
      username:           row[USERNAME_COL],
      level:              row[ACCOUNTTYPE_COL],
      email:              row[EMAIL_COL],
      first_name:         row[FIRSTNAME_COL],
      last_name:          row[LASTNAME_COL],
      full_name:          "#{row[FIRSTNAME_COL]} #{row[LASTNAME_COL]}",
      employee_number:    row[EMPLOYEENUMBER_COL],
      password:           '1rDte@p9q657UtfH&4wQ!',
      sso_id:             sso_id_col_in(row), # THIS CAN BE DIFFERENT BY AIRLINES
      job_title:          row[JOBTITLE_COL],
      address:            row[ADDRESS_COL],
      city:               row[CITY_COL],
      state:              row[STATE_COL],
      zip_code:           row[ZIPCODE_COL],
      mobile_number:      row[MOBILENUMBER_COL],
      work_phone_number:  row[WORKNUMBER_COL],
      disable:            false
    }
  end


  def is_duplicated_username_in_csv(row)
    user_name = row[USERNAME_COL].strip rescue ''
    if @users_in_csv.map(&:username).include? user_name
      @duplicate_username_error << @row_num
      return true
    end
    false
  end


  def is_duplicated_sso_id(row)
    sso_id = sso_id_col_in(row)
    return false if sso_id.nil?
    result = false

    if @users_in_csv.map(&:sso_id).map(&:downcase).include? sso_id
      @duplicate_sso_id_in_csv_error << @row_num
      result =  true
    end

    if check_duplicated_sso_id_in_db(row)
      @duplicate_sso_id_in_portal_error << @row_num
      result = true
    end

    result
  end


  def check_duplicated_sso_id_in_db(row)
    user_name = row[USERNAME_COL].strip rescue ''
    users = User.where(sso_id: sso_id_col_in(row))
    return true if users.size > 1

    users.each do |user|
      return true if user.username.downcase != user_name.downcase
    end

    false
  end


  def have_wrong_num_of_col
    row_size = @table[@row_num-1].size
    if row_size != COLUMN_NUMBER
      @wrong_num_of_col_error << @row_num
      return true
    end
    false
  end


  def upload_users
    @users_in_csv         = []
    @num_created_users    = 0
    @num_re_enabled_users = 0

    # Errors
    @duplicate_username_error          = []
    @duplicate_sso_id_in_csv_error     = []
    @duplicate_sso_id_in_portal_error  = []
    @no_username_error                 = []
    @no_first_name_error               = []
    @no_last_name_error                = []
    @wrong_num_of_col_error            = []
    @unknown_privilege_error           = []
    @unexpected_assign_privilege_error = []
    @unexpected_update_user_error      = []
    @unexpected_create_user_error      = []

    # Number of visible users before update
    @active_users_before_update   = User.all.select{ |user| !user.disable }
    @disabled_users_before_update = User.all.select{ |user|  user.disable }

    first_row = 2
    # Read users row by row
    (first_row..@workbook.last_row).each do |index|
      @row_num = index
      row = @workbook.row(index)

      # Handle duplicated username
      next if is_duplicated_username_in_csv(row)
      # Handle duplicated sso_id
      next if is_duplicated_sso_id(row)
      # Handle wrong number of columns
      next if have_wrong_num_of_col

      user = User.find_by_username(row[USERNAME_COL])
      user_params = get_user_params(row)
      privileges = row[ACCOUNT_PRIVILEGE_COL].split(';').map(&:strip) rescue []

      if should_user_be_updated? (user)
        update_user(user, user_params, privileges)
      elsif user.nil?
        create_user(user_params, privileges)
      end

    end
  end


  def should_user_be_updated?(user)
    user.present? &&            # exists in the database
    user.level != 'External' && # is not External user
    !user.ignore_updates        # is not marked for 'DO NOT UPDATE' check box
  end


  def update_user_privileges(user, privileges)
    privileges.each do |priv|
      privilege =  Privilege.find_by_name(priv)
      if privilege.present?
        unless user.privileges.include? privilege
          begin
            Role.create!(
              users_id: user.id,
              privileges_id: privilege.id
            )
          rescue => e
            puts "#{e} at row ##{@row_num}"
            @logger.info "#{e} at row ##{@row_num}"
            @unexpected_assign_privilege_error << @row_num
          end
        end
      else
        @unknown_privilege_error << @row_num
      end
    end
  end


  def update_user(user, user_params, privileges)
    begin
      was_disabled = user.disable
      user.update_attributes!(user_params)
      update_user_privileges(user, privileges)
      @users_in_csv << user
      @num_re_enabled_users += 1 if was_disabled
    rescue => e
      puts "#{e} at row ##{@row_num}"
      @logger.info "#{e} at row ##{@row_num}"

      user_name = user_params[:username].strip rescue ''
      first_name = user_params[:first_name].strip rescue ''
      last_name = user_params[:last_name].strip rescue ''

      if user_name.empty?
        @no_username_error << @row_num
      elsif first_name.empty?
        @no_first_name_error << @row_num
      elsif last_name.strip.empty?
        @no_last_name_error << @row_num
      else
        @unexpected_update_user_error << @row_num
      end
    end
  end


  def create_user(user_params, privileges)
    begin
      user = User.new(
        username:           user_params[:username],
        level:              user_params[:level],
        email:              user_params[:email],
        first_name:         user_params[:first_name],
        last_name:          user_params[:last_name],
        full_name:          user_params[:full_name],
        employee_number:    user_params[:employee_number],
        sso_id:             user_params[:sso_id],
        job_title:          user_params[:job_title],
        address:            user_params[:address],
        city:               user_params[:city],
        state:              user_params[:state],
        zip_code:           user_params[:zip_code],
        mobile_number:      user_params[:mobile_number],
        work_phone_number:  user_params[:work_phone_number],
        password:           '1rDte@p9q657UtfH&4wQ!',
        disable:            false
      )
      user.save!

      update_user_privileges(user, privileges)
      @num_created_users += 1
      @users_in_csv << user
    rescue => e
      puts "#{e} at row ##{@row_num}"
      @logger.info "#{e} at row ##{@row_num}"

      user_name  = user_params[:username].strip   rescue ''
      first_name = user_params[:first_name].strip rescue ''
      last_name  = user_params[:last_name].strip  rescue ''

      if user_name.empty?
        @no_username_error << @row_num
      elsif first_name.empty?
        @no_first_name_error << @row_num
      elsif last_name.strip.empty?
        @no_last_name_error << @row_num
      else
        @unexpected_create_user_error << @row_num
      end
    end
  end


  def update_historical_file
    IO.copy_stream(@destination, @prev_destination)
  end


  def disable_users
    # Get all users who can be disabled
    all_deletable_users = User.where('ignore_updates = ? AND level != ? AND disable = ?', false, 'External', false)
    # Disable users who were not in CSV file
    users_to_be_disabled = all_deletable_users - @users_in_csv

    @num_deleted_users = users_to_be_disabled.size
    users_to_be_disabled.each do |u|
      u.disable = true
      u.sso_id  = nil
      u.save
    end

    # Number of visible users after update
    @active_users_after_update   = User.all.select{ |user| !user.disable }
    @disabled_users_after_update = User.all.select{ |user|  user.disable }
  end


  def summary
    content =  "\nSUMMARY OF THE DAILY USER IMPORT\n"

    content += "\nBEFORE UPDATE:"
    content += "\n\tTotal Active Users:   " + @active_users_before_update.size.to_s
    content += "\n\tTotal Disabled Users: " + @disabled_users_before_update.size.to_s

    content += "\n\nAFTER UPDATE:"
    content += "\n\tTotal Active Users:   " + @active_users_after_update.size.to_s
    content += "\n\tTotal Disabled Users: " + @disabled_users_after_update.size.to_s

    content += "\n\nUPDATE:"
    content += "\n\tCreated Users:    " + @num_created_users.to_s
    content += "\n\tDisabled Users:   " + @num_deleted_users.to_s
    content += "\n\tRe-enabled Users: " + @num_re_enabled_users.to_s
    content += "\n\n"

    content
  end


  def append_user_id(error_row_array)
    error_row_array.map do |row|
      result  = row.to_s
      users = User.where(sso_id: @table[row-1][sso_id_column])
      user_id = users.reduce('') { |txt, user| txt + "##{user.id}, "}[0...-2]
      result += " (#{user_id})" if user_id.present?
      result
    end
  end


  def get_error_messages
    @duplicate_username_error_msg          = "Duplicated users (in CSV file) found in row(s): #{@duplicate_username_error}\n\n"
    @duplicate_sso_id_in_csv_error_msg     = "Duplicated SSO ID(#{@sso_id}) (in CSV file) found in row(s): #{@duplicate_sso_id_in_csv_error}\n\n"
    @duplicate_sso_id_in_portal_error_msg  = "Duplicated SSO ID(#{@sso_id}) (in portal) found in rows (please find the user #id that has the duplicated sso id in parenthesis): #{append_user_id(@duplicate_sso_id_in_portal_error)}\n\n"
    @no_username_error_msg                 = "Empty username in row(s): #{@no_username_error}\n\n"
    @no_first_name_error_msg               = "Empty first name in row(s): #{@no_first_name_error}\n\n"
    @no_last_name_error_msg                = "Empty last name in row(s): #{@no_last_name_error}\n\n"
    @wrong_num_of_col_error_msg            = "Wrong numbers of column in row(s): #{@wrong_num_of_col_error}\n\n"
    @unknown_privilege_error_msg           = "Unknown user privilege for user(s) in row(s): #{@unknown_privilege_error}\n\n"
    @unexpected_assign_privilege_error_msg = "Failed to assign privileges for user(s) in row(s): #{@unexpected_assign_privilege_error}\n\n"
    @unexpected_update_user_error_msg      = "Failed to update user(s) in row(s): #{@unexpected_update_user_error}\n\n"
    @unexpected_create_user_error_msg      = "Failed to create user(s) in row(s): #{@unexpected_create_user_error}\n\n"

    log_content = ''
    log_content += @duplicate_username_error_msg          if @duplicate_username_error.present?
    log_content += @duplicate_sso_id_in_csv_error_msg     if @duplicate_sso_id_in_csv_error.present?
    log_content += @duplicate_sso_id_in_portal_error_msg  if @duplicate_sso_id_in_portal_error.present?
    log_content += @no_username_error_msg                 if @no_username_error.present?
    log_content += @no_first_name_error_msg               if @no_first_name_error.present?
    log_content += @no_last_name_error_msg                if @no_last_name_error.present?
    log_content += @wrong_num_of_col_error_msg            if @wrong_num_of_col_error.present?
    log_content += @unknown_privilege_error_msg           if @unknown_privilege_error.present?
    log_content += @unexpected_assign_privilege_error_msg if @unexpected_assign_privilege_error.present?
    log_content += @unexpected_update_user_error_msg      if @unexpected_update_user_error.present?
    log_content += @unexpected_create_user_error_msg      if @unexpected_create_user_error.present?

    log_content
  end


  def send_user_import_result
    error_messages = get_error_messages
    email_subject = error_messages.present? ? @email_subject_error : @email_subject
    log_and_notify_user(email_subject: email_subject, msg: summary + error_messages)
  end
end
