require 'roo'

desc 'Import RVF user account information'
task :import_rvf_users => :environment do

  filename = 'rvf_users.xlsx'
  filepath = './lib/tasks/RVF/' + filename
  workbook = Roo::Spreadsheet.open(filepath)

  puts 'Import RVF user account information'

  username_col = 0
  privileges_col = 1
  employee_num_col = 2
  first_name_col = 3
  last_name_col = 4
  email_col = 5
  emp_group_col = 6
  job_title_col = 7

  first_row = 2

  users = []
  level = ''
  count = 0
  total = 0

  (first_row..workbook.last_row).each do |index|
    row = workbook.row(index)

    username        = row[username_col].to_s
    privileges      = row[privileges_col].split(', ')
    employee_number = row[employee_num_col].to_s
    first_name      = row[first_name_col]
    last_name       = row[last_name_col]
    email           = row[email_col]
    emp_group       = row[emp_group_col]
    job_title       = row[job_title_col]
    password        = 'rvf_air2020'

    # Assign account type
    if privileges.include? 'Admin'
      level = 'Global Admin'
    elsif privileges.include? 'Analyst'
      # Set as Analyst temporarily
      # Analyst may be unsupported in future ProSafeT versions
      level = 'Analyst'
    else
      level = 'Staff'
    end

    if (first_name && last_name && email && username)
      total += 1
      count += 1

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

      users << User.new(
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
    end
  end


  User.transaction do
    users.map(&:save!)
  end

  p count.to_s + ' users are created! (out of ' + total.to_s + ')'

  puts 'Assign Privilege based on Account Type'

  global_admin_privileges_id = Privilege.find_by_name('Full Access').id
  sra_analyst_privileges_id  = Privilege.find_by_name('SRA(SRM) Analyst').id
  sra_staff_privileges_id    = Privilege.find_by_name('SRA(SRM) Staff').id

  roles = []

  User.all.each do |user|

    case user.level
    when 'Global Admin'
      privilege = global_admin_privileges_id
    when 'Analyst'
      privilege = sra_analyst_privileges_id
      # Revert to Staff
      user.update_attributes(level: 'Staff')
    when 'Staff'
      privilege = sra_staff_privileges_id
    end

    roles << Role.new(
      users_id: user.id,
      privileges_id: privilege
    )
  end

  Role.transaction do
    roles.map(&:save!)
  end

  p 'Privileges are assigned!'

end
