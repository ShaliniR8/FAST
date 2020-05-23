require 'roo'

desc 'Import FFT user account information'
task :import_fft_user => :environment do

  filename = 'fft_users.xlsx'
  filenpath = './lib/tasks/FFT/' + filename
  workbook = Roo::Spreadsheet.open(filenpath)

  puts 'Import FFT user account information'

  fisrt_name_col = 0
  last_name_col = 1
  email_col = 2
  dept_col = 3

  first_row = 1

  users = []
  level = ''
  count = 0
  total = 0

  (first_row..workbook.last_row).each do |index|
    row = workbook.row(index)

    case row[fisrt_name_col]
    when 'DAG/Manager List'
      level = 'Staff'
    when 'Analyst List'
      level = 'Analyst'
    when 'Administrator List'
      level = 'Global Admin'
    end

    if ( row[fisrt_name_col] && row[last_name_col] && row[email_col] && row[dept_col])
      next if row[fisrt_name_col] == 'First  Name'
      total += 1
      next if User.find_by_username(row[email_col].split('@')[0])
      next if User.find_by_email(row[email_col])

      count += 1

      p row
      p 'username: ' + row[email_col].split('@')[0]
      p 'level ' + level
      p 'email: ' + row[email_col]
      p 'first_name: ' + row[fisrt_name_col]
      p 'last_name: ' + row[last_name_col]
      p 'full_name: ' + row[fisrt_name_col] + ' ' + row[last_name_col]
      p 'job_title: ' + row[dept_col]
      p '-------------------'

      users << User.new(
        username: row[email_col].split('@')[0],
        level: level,
        email:  row[email_col],
        first_name: row[fisrt_name_col],
        last_name:  row[last_name_col],
        full_name: row[fisrt_name_col] + ' ' + row[last_name_col],
        job_title: row[dept_col],
        password: 'prosafet2020!'
      )
    end
  end


  User.transaction do
    users.map(&:save!)
  end

  p count.to_s + ' users are created! (out of ' + total.to_s + ')'

  puts 'Assign Privilege based on Account Type'

  admin_privileges_id = Privilege.find_by_name('SRA Admin').id
  analyst_privileges_id = Privilege.find_by_name('SRA Analyst').id
  manager_privileges_id = Privilege.find_by_name('SRA Manager').id

  roles = []

  User.all.each do |user|

    case user.level
    when 'Global Admin'
      privilege = admin_privileges_id
    when 'Analyst'
      privilege =  analyst_privileges_id
    when 'Staff'
      privilege = manager_privileges_id
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



require 'csv'

task :import_fft_distribution_list => :environment do
  CSV.foreach("#{Dir.pwd}/lib/tasks/FFT/inflight_list.csv") do |row|

    first_name = row[1].strip
    last_name = row[0].strip
    email = row[2].tr('<>', '').strip.downcase

    user = User.where("LOWER(email) = ?", email).first
    puts "#{first_name}, #{last_name}, #{email} => #{user}"

    if !user.present?
      user = User.create(
        username: email.split('@')[0],
        level: 'Staff',
        email: email,
        first_name: first_name,
        last_name: last_name,
        full_name: "#{first_name} #{last_name}",
        job_title: 'Flight Crew Incident Report Receiver',
        password: 'prosafet2020!'
        )
    end

    inflight_prev = Privilege.find_by_name("Inflight Incident: Analyst")
    flight_crew_prev = Privilege.find_by_name("Flight Operations: Incident Analyst")

    #user.privileges << flight_crew_prev
    user.privileges << inflight_prev

  end
end
