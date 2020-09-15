$user_count = 0


desc "Check employee group"
task :check_fft => :environment do

  filename = 'Inflight_Permissions_Verification.xlsx'
  filenpath = './lib/tasks/FFT/' + filename
  xlsx = Roo::Spreadsheet.open(filenpath)

  start_row = 3
  end_row   = xlsx.last_row

  name_col = 0
  employee_num_col = 1

  count = 0

  (start_row..end_row).each do |index|
    row = xlsx.row(index)
    group = User.find_by_employee_number(row[employee_num_col]).privileges[0].name.split(':')[0]
    count += 1
    puts "#{count}: #{row[name_col]} - #{group}"
  end

end


desc "Import FFT SRA Data"
task :import_sra => :environment do

  # ************************************************************************************
  # Reset SRA & Hazard tables (FOR TEST PURPOSE)
  # ActiveRecord::Base.connection.execute("TRUNCATE  sras")
  # ActiveRecord::Base.connection.execute("TRUNCATE  hazards")
  # ActiveRecord::Base.connection.execute("TRUNCATE  risk_controls")
  # ************************************************************************************

  filename = 'fft_sra.xlsx'
  filenpath = './lib/tasks/FFT/' + filename
  xlsx = Roo::Spreadsheet.open(filenpath)

  start_row = 2
  end_row   = xlsx.last_row

  create_sras(xlsx, start_row, end_row) # and hazards & risk controls

  puts "[Info] DONE"
  puts "# of the users created: #{$user_count}"
end

def create_sras(xlsx, start_row, end_row)
  col_submit_date    = 1
  col_last_name      = 4
  col_first_name     = 5
  col_username       = 6
  col_ref_num        = 9
  col_sra_title      = 10
  col_form_date      = 11
  col_type_of_change = 12
  col_current_system = 101
  col_proposed_plan  = 102
  col_department     = 124

  (start_row..end_row).each do |index|
    row = xlsx.row(index)

    created_at = row[col_submit_date]

    # TODO: find user
    username  = row[col_username]
    first_name = row[col_first_name]
    last_name  = row[col_last_name]
    user = check_user(username, last_name, first_name)
    title = row[col_ref_num].present? ? "#{row[col_ref_num]}: #{row[col_sra_title]}" : row[col_sra_title]

    # set departments
    departments = []
    CONFIG.custom_options['Departments'].each do |department|
      if department == row[col_department]
        departments << department
      elsif department == 'Maintenance' && row[col_department] == 'Maintenance Department'
        departments << 'Maintenance Department'
      else
        departments << ''
      end
    end

    # TODO: create Sra
    if user.present?
      sra = Sra.create(
        status: 'Completed',
        responsible_user_id: user.id,
        title: title,
        close_date: row[col_form_date],
        type_of_change: row[col_type_of_change],
        current_description: row[col_current_system],
        plan_description: row[col_proposed_plan],
        departments: departments,
        created_at: created_at
      )
    else
      sra = Sra.create(
        status: 'Completed',
        title: title,
        close_date: row[col_form_date],
        type_of_change: row[col_type_of_change],
        current_description: row[col_current_system],
        plan_description: row[col_proposed_plan],
        departments: departments,
        created_at: created_at
      )
    end

    puts "[Info] Create SRA - title: #{row[col_sra_title]}"

    # TODO: create hazards belongs to the SRA
    create_hazards(user, row, sra, row[col_department])
  end
end

def create_hazards(user, row, sra, department)

  # HAZARD 1
  col_hazard1_risk_factor       = 27
  col_hazard1_risk_factor_after = 36
  col_hazard1_title             = 103
  col_hazard1_substitute_hazard = 108
  col_severity                  = 125
  col_hazard1_severity          = 126
  col_hazard1_likelihood        = 127
  col_hazard1_severity2         = 132
  col_hazard1_likelihood2       = 133

  # HAZARD 2
  col_hazard2_risk_factor       = 49
  col_hazard2_risk_factor_after = 58
  col_hazard2_title             = 109
  col_hazard2_substitute_hazard = 114
  col_hazard2_severity          = 138
  col_hazard2_likelihood        = 139
  col_hazard2_severity2         = 144
  col_hazard2_likelihood2       = 145

  # HAZARD 3
  col_hazard3_risk_factor       = 69
  col_hazard3_risk_factor_after = 76
  col_hazard3_title             = 115
  col_hazard3_substitute_hazard = 119
  col_hazard3_severity          = 150
  col_hazard3_likelihood        = 151
  col_hazard3_severity2         = 155
  col_hazard3_likelihood2       = 156

  # HAZARD 4
  col_hazard4_risk_factor       = 86
  col_hazard4_risk_factor_after = 91
  col_hazard4_title             = 120
  col_hazard4_substitute_hazard = 123
  col_hazard4_severity          = 161
  col_hazard4_likelihood        = 162
  col_hazard4_severity2         = 165
  col_hazard4_likelihood2       = 166

  severity_type_map = {
    'Regulatory'                    => 0,
    'Accident/Incident/Damage/OSHA' => 1,
    'Operational Events'            => 2,
    'Company Impact'                => 3
  }

  likelihood_map = {
    '2 Remote'     => 0,
    '3 Seldom'     => 1,
    '4 Occasional' => 2,
    '5 Probable'   => 3,
    '6 Frequent'   => 4
  }

  severity_map = {
    '1 Negligible' => 0,
    '2 Minor' => 1,
    '3 Moderate' => 2,
    '4 Critical' => 3,
    '5 Catastrophic' => 4
  }

  risk_factor_map = {
    2  => 'Low - 2',
    3  => 'Low - 3',
    4  => 'Low - 4',
    5  => 'Low - 5',
    6  => 'Low - 6',
    8  => 'Minor - 8',
    9  => 'Minor - 9',
    10 => 'Minor - 10',
    12 => 'Medium - 12',
    15 => 'Medium - 15',
    16 => 'Medium - 16',
    18 => 'Serious - 18',
    20 => 'Serious - 20',
    24 => 'High - 24',
    25 => 'High - 25',
    30 => 'High - 30',
  }

  # Hazard 1
  if row[col_hazard1_title].present?
    severity_type = severity_type_map[row[col_severity1]]
    title         = row[col_hazard1_title].slice(0, 255)
    description   = row[col_hazard1_title]
    final_comment = row[col_hazard1_substitute_hazard]

    severity    = severity_map[row[col_hazard1_severity]]
    likelihood  = likelihood_map[row[col_hazard1_likelihood]]
    risk_factor = risk_factor_map[row[col_hazard1_risk_factor]]

    severity_after    = severity_map[row[col_hazard1_severity2]]
    likelihood_after  = likelihood_map[row[col_hazard1_likelihood2]]
    risk_factor_after = risk_factor_map[row[col_hazard1_risk_factor_after]]


    hazard1 = create_hazard(user, sra, severity_type, title, description, department, final_comment, severity, likelihood, risk_factor, severity_after, likelihood_after, risk_factor_after)
    puts "  Create Hazard 1 - title: #{row[col_hazard1_title]}"
    create_risk_controls1(row, hazard1)
  else
    puts "  Hazard 1 Does Not Exist"
  end

  # Hazard 2
  if row[col_hazard2_title].present?
    severity_type = severity_type_map[row[col_severity]]
    title         = row[col_hazard2_title].slice(0, 255)
    description   =  row[col_hazard2_title]
    final_comment = row[col_hazard2_substitute_hazard]

    severity    = severity_map[row[col_hazard2_severity]]
    likelihood  = likelihood_map[row[col_hazard2_likelihood]]
    risk_factor = risk_factor_map[row[col_hazard2_risk_factor]]

    severity_after    = severity_map[row[col_hazard2_severity2]]
    likelihood_after  = likelihood_map[row[col_hazard2_likelihood2]]
    risk_factor_after = risk_factor_map[row[col_hazard2_risk_factor_after]]

    hazard2 = create_hazard(user, sra, severity_type, title, description, department, final_comment, severity, likelihood, risk_factor, severity_after, likelihood_after, risk_factor_after)
    puts "  Create Hazard 2 - title: #{row[col_hazard2_title]}"
    create_risk_controls2(row, hazard2)
  else
    puts "  Hazard 2 Does Not Exist"
  end

  # Hazard 3
  if row[col_hazard3_title].present?
    severity_type = severity_type_map[row[col_severity]]
    title         = row[col_hazard3_title].slice(0, 255)
    description   =  row[col_hazard3_title]
    final_comment = row[col_hazard3_substitute_hazard]

    severity    = severity_map[row[col_hazard3_severity]]
    likelihood  = likelihood_map[row[col_hazard3_likelihood]]
    risk_factor = risk_factor_map[row[col_hazard3_risk_factor]]

    severity_after    = severity_map[row[col_hazard3_severity2]]
    likelihood_after  = likelihood_map[row[col_hazard3_likelihood2]]
    risk_factor_after = risk_factor_map[row[col_hazard3_risk_factor_after]]

    hazard3 = create_hazard(user, sra, severity_type, title, description, department, final_comment, severity, likelihood, risk_factor, severity_after, likelihood_after, risk_factor_after)
    puts "  Create Hazard 3 - title: #{row[col_hazard3_title]}"
    create_risk_controls3(row, hazard3)
  else
    puts "  Hazard 3 Does Not Exist"
  end

  # Hazard 4
  if row[col_hazard4_title].present?
    severity_type = severity_type_map[row[col_severity]]
    title         = row[col_hazard4_title].slice(0, 255)
    description   =  row[col_hazard4_title]
    final_comment = row[col_hazard4_substitute_hazard]

    severity    = severity_map[row[col_hazard4_severity]]
    likelihood  = likelihood_map[row[col_hazard4_likelihood]]
    risk_factor = risk_factor_map[row[col_hazard4_risk_factor]]

    severity_after    = severity_map[row[col_hazard4_severity2]]
    likelihood_after  = likelihood_map[row[col_hazard4_likelihood2]]
    risk_factor_after = risk_factor_map[row[col_hazard4_risk_factor_after]]

    hazard4 = create_hazard(user, sra, severity_type, title, description, department, final_comment, severity, likelihood, risk_factor, severity_after, likelihood_after, risk_factor_after)
    puts "  Create Hazard 4 - title: #{row[col_hazard4_title]}"
    create_risk_controls4(row, hazard4)
  else
    puts "  Hazard 4 Does Not Exist"
  end
end


def create_hazard(user, sra, severity_type, title, description, department, final_comment, severity, likelihood, risk_factor, severity_after, likelihood_after, risk_factor_after)
  severity_extra = []
  (0..3).each do |severity|
    if severity_type == severity
      severity_extra << severity
    else
      severity_extra << "undefined"
    end
  end

  mitigated_severity = []
  (0..3).each do |severity|
    if severity_type == severity
      mitigated_severity << severity_after
    else
      mitigated_severity << "undefined"
    end
  end

  probability_extra = [likelihood],
  mitigated_probability = [likelihood_after]


  if user.present?
    Hazard.create(
      status: 'Completed',
      sra_id: sra.id,
      title: title,
      approver_id: user.id,
      description: description,
      departments: department,

      final_comment: final_comment,

      severity: severity,
      likelihood: likelihood,
      risk_factor: risk_factor,

      severity_after: severity_after,
      likelihood_after: likelihood_after,
      risk_factor_after: risk_factor_after,

      severity_extra: severity_extra,
      probability_extra: probability_extra,

      mitigated_severity: mitigated_severity,
      mitigated_probability: mitigated_probability
    )
  else
    Hazard.create(
      status: 'Completed',
      sra_id: sra.id,
      title: title,
      description: description,
      departments: department,

      final_comment: final_comment,

      severity: severity,
      likelihood: likelihood,
      risk_factor: risk_factor,

      severity_after: severity_after,
      likelihood_after: likelihood_after,
      risk_factor_after: risk_factor_after,

      severity_extra: severity_extra,
      probability_extra: probability_extra,

      mitigated_severity: mitigated_severity,
      mitigated_probability: mitigated_probability
    )
  end
end

def create_risk_controls1(row, hazard)

  # *** HAZARD 1 ***
  # RISK CONTROL 1
  col_risk1_responsible_user  = 28
  col_risk1_due_date          = 29
  col_risk1_title             = 104
  col_risk1_department        = 128

  # RISK CONTROL 2
  col_risk2_responsible_user  = 30
  col_risk2_due_date          = 31
  col_risk2_title             = 105
  col_risk2_department        = 129

  # RISK CONTROL 3
  col_risk3_responsible_user  = 32
  col_risk3_due_date          = 33
  col_risk3_title             = 106
  col_risk3_department        = 130

  # RISK CONTROL 4
  col_risk4_responsible_user  = 34
  col_risk4_due_date          = 35
  col_risk4_title             = 107
  col_risk4_department        = 131


  if row[col_risk1_title].present?
    title = row[col_risk1_title].slice(0, 255)
    due_date = row[col_risk1_due_date]
    description = row[col_risk1_title]
    department = row[col_risk1_department]
    responsible_user = check_fullname(row[col_risk1_responsible_user])
    puts "  Create RiskControl 1-1 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 1-1 Does Not Exist"
  end

  if row[col_risk2_title].present?
    title = row[col_risk2_title].slice(0, 255)
    due_date = row[col_risk2_due_date]
    description = row[col_risk2_title]
    department = row[col_risk2_department]
    responsible_user = check_fullname(row[col_risk2_responsible_user])

    puts "  Create RiskControl 1-2 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 1-2 Does Not Exist"
  end

  if row[col_risk3_title].present?
    title = row[col_risk3_title].slice(0, 255)
    due_date = row[col_risk3_due_date]
    description = row[col_risk3_title]
    department = row[col_risk3_department]
    responsible_user = check_fullname(row[col_risk3_responsible_user])

    puts "  Create RiskControl 1-3 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 1-3 Does Not Exist"
  end

  if row[col_risk4_title].present?
    title = row[col_risk4_title].slice(0, 255)
    due_date = row[col_risk4_due_date]
    description = row[col_risk4_title]
    department = row[col_risk4_department]
    responsible_user = check_fullname(row[col_risk4_responsible_user])

    puts "  Create RiskControl 1-4 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 1-4 Does Not Exist"
  end
end


def create_risk_controls2(row, hazard)

  # *** HAZARD 2 ***
  # RISK CONTROL 1
  col_risk1_responsible_user  = 50
  col_risk1_due_date          = 51
  col_risk1_title             = 110
  col_risk1_department        = 140

  # RISK CONTROL 2
  col_risk2_responsible_user  = 52
  col_risk2_due_date          = 53
  col_risk2_title             = 111
  col_risk2_department        = 141

  # RISK CONTROL 3
  col_risk3_responsible_user  = 54
  col_risk3_due_date          = 55
  col_risk3_title             = 112
  col_risk3_department        = 142

  # RISK CONTROL 4
  col_risk4_responsible_user  = 56
  col_risk4_due_date          = 57
  col_risk4_title             = 113
  col_risk4_department        = 143


  if row[col_risk1_title].present?
    title = row[col_risk1_title].slice(0, 255)
    due_date = row[col_risk1_due_date]
    description = row[col_risk1_title]
    department = row[col_risk1_department]
    responsible_user = check_fullname(row[col_risk1_responsible_user])

    puts "  Create RiskControl 2-1 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 2-1 Does Not Exist"
  end

  if row[col_risk2_title].present?
    title = row[col_risk2_title].slice(0, 255)
    due_date = row[col_risk2_due_date]
    description = row[col_risk2_title]
    department = row[col_risk2_department]
    responsible_user = check_fullname(row[col_risk2_responsible_user])

    puts "  Create RiskControl 2-2 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 2-2 Does Not Exist"
  end

  if row[col_risk3_title].present?
    title = row[col_risk3_title].slice(0, 255)
    due_date = row[col_risk3_due_date]
    description = row[col_risk3_title]
    department = row[col_risk3_department]
    responsible_user = check_fullname(row[col_risk3_responsible_user])

    puts "  Create RiskControl 2-3 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 2-3 Does Not Exist"
  end

  if row[col_risk4_title].present?
    title = row[col_risk4_title].slice(0, 255)
    due_date = row[col_risk4_due_date]
    description = row[col_risk4_title]
    department = row[col_risk4_department]
    responsible_user = check_fullname(row[col_risk4_responsible_user])

    puts "  Create RiskControl 2-4 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 2-4 Does Not Exist"
  end
end


def create_risk_controls3(row, hazard)

  # *** HAZARD 3 ***
  # RISK CONTROL 1
  col_risk1_responsible_user  = 70
  col_risk1_due_date          = 71
  col_risk1_title             = 116
  col_risk1_department        = 152

  # RISK CONTROL 2
  col_risk2_responsible_user  = 72
  col_risk2_due_date          = 73
  col_risk2_title             = 117
  col_risk2_department        = 153

  # RISK CONTROL 3
  col_risk3_responsible_user  = 74
  col_risk3_due_date          = 75
  col_risk3_title             = 118
  col_risk3_department        = 154


  if row[col_risk1_title].present?
    title = row[col_risk1_title].slice(0, 255)
    due_date = row[col_risk1_due_date]
    description = row[col_risk1_title]
    department = row[col_risk1_department]
    responsible_user = check_fullname(row[col_risk1_responsible_user])

    puts "  Create RiskControl 3-1 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 3-1 Does Not Exist"
  end

  if row[col_risk2_title].present?
    title = row[col_risk2_title].slice(0, 255)
    due_date = row[col_risk2_due_date]
    description = row[col_risk2_title]
    department = row[col_risk2_department]
    responsible_user = check_fullname(row[col_risk2_responsible_user])

    puts "  Create RiskControl 3-2 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 3-2 Does Not Exist"
  end

  if row[col_risk3_title].present?
    title = row[col_risk3_title].slice(0, 255)
    due_date = row[col_risk3_due_date]
    description = row[col_risk3_title]
    department = row[col_risk3_department]
    responsible_user = check_fullname(row[col_risk3_responsible_user])

    puts "  Create RiskControl 3-3 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 3-3 Does Not Exist"
  end
end

def create_risk_controls4(row, hazard)

  # *** HAZARD 4 ***
  # RISK CONTROL 1
  col_risk1_responsible_user  = 87
  col_risk1_due_date          = 88
  col_risk1_title             = 121
  col_risk1_department        = 163

  # RISK CONTROL 2
  col_risk2_responsible_user  = 89
  col_risk2_due_date          = 90
  col_risk2_title             = 122
  col_risk2_department        = 164


  if row[col_risk1_title].present?
    title = row[col_risk1_title].slice(0, 255)
    due_date = row[col_risk1_due_date]
    description = row[col_risk1_title]
    department = row[col_risk1_department]
    responsible_user = check_fullname(row[col_risk1_responsible_user])

    puts "  Create RiskControl 4-1 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 4-1 Does Not Exist"
  end

  if row[col_risk2_title].present?
    title = row[col_risk2_title].slice(0, 255)
    due_date = row[col_risk2_due_date]
    description = row[col_risk2_title]
    department = row[col_risk2_department]
    responsible_user = check_fullname(row[col_risk2_responsible_user])

    puts "  Create RiskControl 4-2 - title: #{title}"
    create_risk_control(hazard, title, responsible_user, due_date, description, department)
  else
    puts "  RiskControl 4-2 Does Not Exist"
  end
end


def create_risk_control(hazard, title, responsible_user, due_date, description, department)

  if responsible_user.nil?
    RiskControl.create(
      status: 'Completed',
      hazard_id: hazard.id,
      title: title,
      due_date: due_date,

      description: description,
      departments: department,
    )
  else
    RiskControl.create(
      status: 'Completed',
      hazard_id: hazard.id,
      title: title,
      responsible_user_id: responsible_user.id,
      due_date: due_date,

      description: description,
      departments: department,
    )
  end
end

def check_user(username, last_name, first_name)
  # check username
  user = User.find_by_username(username)
  if user.nil?
    # check full name
    user = User.where(last_name: last_name, first_name: first_name)[0]
    if user.nil?
      puts "[****] Can't find the USER #{first_name} #{last_name}"
      $user_count = $user_count + 1
      user = User.create(
        username: username,
        last_name: last_name,
        first_name: first_name,
        disable: 1,
        password: 'prosafet2020!',
        employee_number: $user_count
      )
    else
      puts "[info] FULLNAME: #{first_name} #{last_name} is found."
    end
  else
    puts "[info] USERNAME: #{username} is found."
  end

  return user
end

def check_fullname(fullname)
  # byebug if fullname == 'Alex Blazewicz'
  # byebug if fullname == 'Ty Steers'
  user = User.find_by_full_name(fullname)
  if user.nil?
    puts "[****] Can't find the USER #{fullname}"

    return nil if fullname.nil?
    if fullname.include? ','

      username = fullname.split(', ')[1].downcase + '.' + fullname.split(', ')[0].downcase
      $user_count = $user_count + 1
      user = User.create(
        username: username,
        first_name: fullname.split(', ')[1],
        last_name: fullname.split(', ')[0],
        full_name: fullname,
        disable: 1,
        password: 'prosafet2020!',
        employee_number: $user_count
      )
    else

      if fullname.split(' ')[1].nil?
        username = fullname.split(' ')[0].downcase
        fullname = username + ' FFT'
      else
        username = fullname.split(' ')[0].downcase + '.' + fullname.split(' ')[1].downcase
      end
      $user_count = $user_count + 1
      user = User.create(
        username: username.gsub('/', '').gsub("\'", ''),
        first_name: fullname.split(' ')[0],
        last_name: fullname.split(' ')[1],
        full_name: fullname,
        disable: 1,
        password: 'prosafet2020!',
        employee_number: $user_count
      )
    end

  else
    puts "[info] FULLNAME: #{fullname} is found."
  end

  if user.invalid?
    $user_count = $user_count - 1
    user = User.find_by_username(username)
  end

  if user.full_name.nil?
    user.full_name = user.first_name + ' ' + user.last_name
    user.save
  end

  byebug if user.invalid?

  return user
end
