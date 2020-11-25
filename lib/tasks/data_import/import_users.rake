require 'roo'

desc "Import user account information"
task :import_users => :environment do
  puts "Import #{AIRLINE_CODE} user account information"
  # select module to assign privileges for
  # MODULE_NAME = 'ASAP'
  # MODULE_NAME = 'SMS IM'
  # MODULE_NAME = 'SMS'
  MODULE_NAME = 'SRM'
  ASAP_MODULE            = MODULE_NAME == 'ASAP' ? true : false
  ASAP_USER_GROUPS       = ['ASAP', 'Fatigue', 'Incident']
  FULL_ACCESS_PRIVILEGE  = Privilege.find_by_name('Full Access')
  SRA_ANALYST_PRIVILEGE  = Privilege.find_by_name('SRA(SRM) Analyst')
  SRA_STAFF_PRIVILEGE    = Privilege.find_by_name('SRA(SRM) Staff')
  SA_ANALYST_PRIVILEGE  = Privilege.find_by_name('SA Analyst')
  SA_STAFF_PRIVILEGE    = Privilege.find_by_name('SA Staff')

  # select airline user input specific information
  AIRLINE_EMAIL       = 'ravnalaska.com'
  # ex: rvf_air2020
  DEFAULT_PASSWORD    = "#{AIRLINE_CODE.downcase}_air#{Date.today.year}"
  CUSTOM_PASSWORD     = ''
  PASSWORD_PROVIDED   = false
  USERNAME_PROVIDED   = true
  EMAIL_PROVIDED      = true

  filename = "#{AIRLINE_CODE}_#{MODULE_NAME}_Users.xlsx"
  filepath = "./lib/tasks/#{AIRLINE_CODE}/" + filename
  workbook = Roo::Spreadsheet.open(filepath)


  # Spreadsheet infromation
  USERNAME_COL      = 0
  PRIVILEGES_COL    = 1
  EMPLOYEE_NUM_COL  = 2
  FIRST_NAME_COL    = 3
  LAST_NAME_COL     = 4
  EMAIL_COL         = 5
  EMP_GROUP_COL     = 6
  JOB_TITLE_COL     = 7
  FIRST_ROW         = 2

  roles               = []
  new_users           = []
  account_privileges  = []
  emp_groups          = []
  level               = ''
  count               = 0
  total               = 0

  (FIRST_ROW..workbook.last_row).each do |i|
    row = workbook.row(i)
    total += 1

    username            = row[EMPLOYEE_NUM_COL].to_s
    privileges_string   = row[PRIVILEGES_COL]
    employee_number     = row[EMPLOYEE_NUM_COL].to_s
    first_name          = row[FIRST_NAME_COL]
    last_name           = row[LAST_NAME_COL]
    email               = row[EMAIL_COL]
    emp_group           = row[EMP_GROUP_COL]
    job_title           = row[JOB_TITLE_COL]
    password            = PASSWORD_PROVIDED ? CUSTOM_PASSWORD : DEFAULT_PASSWORD

    # user input validation
    employee_group    ||= ''
    job_title         ||= ''
    privileges_string ||= ''

    # assign account type according to privileges
    if privileges_string.include? 'Admin'
      level = 'Global Admin'
    elsif privileges_string.include? 'Analyst'
      level = 'Analyst'
    else
      level = 'Staff'
    end

    username = employee_number if !USERNAME_PROVIDED
    email    = "#{first_name.downcase}.#{last_name.downcase}@#{AIRLINE_EMAIL}" if !EMAIL_PROVIDED

    # required information
    if (username.present? && first_name.present? && last_name.present? && email.present?)

      p row
      p 'username: '       + username
      p 'employee #: '     + employee_number
      p 'first_name: '     + first_name
      p 'last_name: '      + last_name
      p 'full_name: '      + first_name + ' ' + last_name
      p 'email: '          + email
      p 'employee group: ' + emp_group
      p 'job title: '      + job_title
      p 'level: '          + level
      p '-------------------'

      new_users << User.new(
        username:        username,
        level:           level,
        email:           email,
        first_name:      first_name,
        last_name:       last_name,
        full_name:       first_name + ' ' + last_name,
        job_title:       job_title,
        employee_number: employee_number,
        password:        password
      )
      account_privileges << privileges_string
      emp_groups << emp_group
      count += 1
    end
  end


  User.transaction do
    new_users.each(&:save!)
  end

  puts count.to_s + ' users are created! (out of ' + total.to_s + ')'
  puts 'Assign Privileges based on Employee Group'      if ASAP_MODULE
  puts 'Assign Privileges based on Account Privileges'  if !ASAP_MODULE

  privileges_index  = 0
  emp_groups_index  = 0

  new_users.each do |user|
      privileges = []
    if user.level == 'Global Admin'
      privileges << FULL_ACCESS_PRIVILEGE
    else
      analyst = false
      type = 'Submitter'
      if user.level == 'Analyst'
        # revert to Staff because Analyst may be removed as a user level
        user.update_attributes(level: 'Staff')
        type = 'Analyst'
        analyst = true
      end
      case MODULE_NAME
      when 'ASAP'
        # add privileges according to employee group
        emp_group  = emp_groups[emp_groups_index]
        # only Incident if General submitter
        if emp_group == 'General'
          privileges << Privilege.find_by_name("General: Incident #{type}")
        else
          ASAP_USER_GROUPS.each do |group|
            privileges << Privilege.find_by_name("#{emp_group}: #{group} #{type}")
          end
          privileges << Privilege.find_by_name("General: Incident #{type}")
        end
      when'SRM'
        if analyst
          privileges << SRA_ANALYST_PRIVILEGE
          # revert to Staff because Analyst may be removed as a user level
        else
          privileges<< SRA_STAFF_PRIVILEGE
        end
      when 'SMS'
        if analyst
          privileges << SA_ANALYST_PRIVILEGE
        else
          privileges<< SA_STAFF_PRIVILEGE
        end
      else
        # SMS IM
      end
    end
    # puts "==adding privilege: #{privileges[-1]} for user: #{user.username}"
    # create the role for each privilege
    privileges.each do |p|
      roles << Role.new(
        users_id: user.id,
        privileges_id: p.id)
    end
    privileges_index  = privileges_index + 1
    emp_groups_index  = emp_groups_index + 1
  end

  Role.transaction do
    roles.map(&:save!)
  end

  puts 'Privileges are assigned!'

end
