namespace :ultipro do
  @filepath = '/home/jiaming/dylan/Ultipro_POC.xml'
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

  task :import_users, [:filepath] => [:environment] do |t, args|
    begin
      data_dump = File.read(@filepath)
    rescue
      puts "[ERROR] #{@filepath} could not be opened"
      next #Abort
    end

    @process = []
    @privilege_list = {}
    Privilege.all.each{ |priv| @privilege_list[priv[:name]] = priv.id }

    puts '### Generating Users ###'
    Hash.from_xml(data_dump)['wbat_poc']['poc'].each do |u|

      user = User.new({
        username: u['user_name'],
        email: u['email_address'],
        full_name: "#{u['first_name']} #{u['last_name']}",
        first_name: u['first_name'],
        last_name: u['last_name'],
        sso_id: u['email_address'],
        password: 'ObfUsCaTeD_pAsSwOrD',
        employee_number: u['employee_number'],
        level: map_account_level(u['employee_group'])
      })
      begin
        user.save! if !@dry_run
      rescue
        @process << "[WARNING] User #{u['user_name']} data error- Skipped\n   #{u}"
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
          priv =  "#{pr['employee_group']}: #{pr['access_group']}"
          generate_privilege priv unless @privilege_list.key? priv
          user.roles.new({privileges_id: @privilege_list[priv]}).save! if !@dry_run
          puts "  #{priv}" if @expand_output
        end
        print '.' if !@expand_output

      rescue
        if defined?(privileges)
          @process << "[NOTICE] Privileges not read for user #{user.full_name}:\n   -#{privileges || 'No privileges found'}"
        else
          @process << "[INFO] No privileges found for user #{user.full_name}"
        end
        print '*' if !@expand_output
      end
    end

    puts "\n### Task Notes ###"
    @process.each do |event|
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
      @process << "[INFO] Generated New Privilege: #{title}"
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
