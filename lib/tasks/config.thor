class Config < Thor
  require 'erb'

  desc 'init |__AIRLINE_CODE__|', 'Not yet implemented'
  def init(airline_code)
    #cmd = "mysql -e \"CREATE DATABASE #{database['database']};\""
    # TODO
  end

  desc 'set_airline |__AIRLINE_CODE__|', 'Sets the airline_code.yml and database.yml files'
  def set_airline(airline_code)
    puts '##########################'
    puts '|| SETTING AIRLINE CODE ||'
    puts '##########################'
    puts "\nAIRLINE CODE: #{airline_code}\n\n"

    @airline_code = airline_code
    set_airline_code
    set_enabled_systems_and_environments
    set_database_yml
  end

  desc 'wipe_tables', 'Clears all user-input fields; users, privileges, and rules are maintained'
  def wipe_tables(environment='development')
    require File.expand_path('config/environment.rb')
    puts '############################'
    puts '|| WIPING DATABASE TABLES ||'
    puts '############################'
    target_db = Rails.configuration.database_configuration[environment]['database']
    puts "This Database is the target: #{target_db}"
    puts 'To confirm the clearing of this database, please type out the full database name and hit ENTER'
    input = STDIN.gets
    if input[0...-1] != target_db
      puts 'Confirmation failed - aborting task'
      return
    end
    spec = User.configurations[RAILS_ENV].clone
    spec['database'] = target_db
    ActiveRecord::Base.establish_connection(spec)
    %w[
      access_levels
      agendas
      attachments
      audits
      automated_notifications
      causes
      checklist_cells
      checklist_headers
      checklist_items
      checklist_questions
      checklist_records
      checklist_rows
      checklist_templates
      checklists
      contacts
      children
      corrective_actions
      costs
      documents
      evaluations
      expectations
      extension_requests
      faa_reports
      findings
      hazards
      ims
      inspections
      investigations
      issues
      meetings
      message_accesses
      messages
      notices
      occurrences
      orm_submission_fields
      orm_submissions
      packages
      parents
      participations
      private_links
      query_conditions
      query_statements
      recommendations
      record_fields
      records
      recurrences
      report_meetings
      reports
      risk_controls
      root_causes
      safety_plans
      section_fields
      sections
      signatures
      sms_actions
      sms_tasks
      sras
      submission_fields
      submissions
      trackings
      transactions
      verifications
      viewer_comments
    ].each do |table|
      print "Truncating #{Rails.configuration.database_configuration[environment]['database']}:#{table}..."
      ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
      puts ' Truncated!'
    end
  end

  private

  def set_airline_code
    puts "Setting airline_code.yml with value '#{@airline_code}'..."
    Dir.glob("**/airline_code.yml.erb").each do |path|
      transpile_erb path, binding
    end
    puts "\t...done."
  end

  def set_database_yml
    puts "Configuring database.yml for '#{@airline_code}'..."
    Dir.glob("**/database.yml.erb").each do |path|
      transpile_erb path, binding
    end
    puts "\t...done."
  end

  #Reads provided file, uses the binding (defined variables) to interpret the file,
  #Then write it all to a file with identical name minus the '.erb'
  def transpile_erb(filename, bindings)
    File.open(filename, 'r') do |template|
      erb = ERB.new(template.read)
      new_filename = filename.gsub(/\.erb/, '')
      File.open(new_filename, 'w') do |f|
        f.write erb.result(bindings)
      end
    end
  end

  #Defines ENABLED_SYSTEMS and SYSTEM_ENVIRONMENTS from the airline config for use in the thor task
  def set_enabled_systems_and_environments
    config = File.join('app', 'models', 'systems', "#{underscore(@airline_code)}", "#{underscore(@airline_code)}_config.rb")

    if File.exists?(config)
      File.open(config, 'r') do |f|
        f.each_line do |line|
          if line =~ /(ENABLED\_SYSTEMS\s*=.*$)/
            eval $1
            break
          end
        end
      end
      File.open(config, 'r') do |f|
        f.each_line do |line|
          if line =~ /(SYSTEM\_ENVIRONMENTS\s*=.*$)/
            eval $1
            break
          end
        end
      end

      unless defined? ENABLED_SYSTEMS
        throw "ERROR: ENABLED_SYSTEMS is not defined in `#{config}`"
      end
      unless defined? SYSTEM_ENVIRONMENTS
        throw "ERROR: SYSTEM_ENVIRONMENTS is not defined in `#{config}`"
      end
    else
      throw "ERROR: File `#{config}` was not found"
    end
  end


  def underscore(camel_cased_word)
    return camel_cased_word unless /[A-Z-]|::/ =~ camel_cased_word
    word = camel_cased_word.to_s.gsub('::', '/')
    word.gsub!(/\s/, '_')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!('-', '_')
    word.downcase!
    word
  end


end
