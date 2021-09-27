namespace :audit_migration do

  task :migrate_audits => :environment do
    begin
      @logger = Logger.new("log/migrate_audits.log")
      @audit_created_count = 0
      @causes_created_count = 0
      @audit_failed_count = 0
      @user_created_count = 0

      begin_audit_migration_log
      create_mappings
      start_audit_migration_process

      end_audit_migration_log
    rescue => error
      @logger.info "[ERROR][MAIN_TASK]: #{error.message}"
    end
  end

  def begin_audit_migration_log
    @logger.info '############################'
    @logger.info '### MIGRATING OLD AUDITS ###'
    @logger.info '############################'
    @logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"
  end


  def create_mappings
    @core_field_mapping = Hash.new
    @core_field_mapping["rsap"] = Hash.new
    @core_field_mapping["rsap"]["auditor"] = [:responsible_user_id, :created_by_id]
    @core_field_mapping["rsap"]["date of event"] = [:close_date]
    @core_field_mapping["rsap"]["codeshare"] = [:audit_department]
    @core_field_mapping["rsap"]["audit type"] = [:audit_type]
    @core_field_mapping["rsap"]["location"] = [:location, :station_code]


    @core_field_mapping["finding"] = Hash.new
    @core_field_mapping["finding"]["auditing department"] = [:department]
    @core_field_mapping["finding"]["incident number"] = [:title]
    @core_field_mapping["finding"]["codeshare"] = [:created_by_id]
    @core_field_mapping["finding"]["report date"] = [:due_date]
    @core_field_mapping["finding"]["date of incident"] = [:close_date]
    @core_field_mapping["finding"]["gate"] = [:location]
    @core_field_mapping["finding"]["location"] = [:station_code]
    @core_field_mapping["finding"]["ground handler"] = [:vendor]
    @core_field_mapping["finding"]["regulation"] = [:reference]
    @core_field_mapping["finding"]["description"] = [:instruction]
    @core_field_mapping["finding"]["corrective actions"] = [:comment]
    @core_field_mapping["finding"]["follow-up"] = [:final_comment]


    @core_field_mapping["enforcement"] = Hash.new
    @core_field_mapping["enforcement"]["auditing department"] = [:department]
    @core_field_mapping["enforcement"]["case number"] = [:title]
    @core_field_mapping["enforcement"]["addressed to"] = [:created_by_id]
    @core_field_mapping["enforcement"]["assigned to"] = [:approver_id]
    @core_field_mapping["enforcement"]["date of response"] = [:due_date]
    @core_field_mapping["enforcement"]["closing action dated"] = [:close_date]
    @core_field_mapping["enforcement"]["location"] = [:location, :station_code]
    @core_field_mapping["enforcement"]["regulation"] = [:reference]
    @core_field_mapping["enforcement"]["description"] = [:comment]
    @core_field_mapping["enforcement"]["closing action"] = [:final_comment]


    @core_field_mapping["inspection"] = Hash.new
    @core_field_mapping["inspection"]["auditing department"] = [:department]
    @core_field_mapping["inspection"]["incident number"] = [:title]
    @core_field_mapping["inspection"]["codeshare"] = [:created_by_id]
    @core_field_mapping["inspection"]["report date"] = [:due_date]
    @core_field_mapping["inspection"]["date of incident"] = [:close_date]
    @core_field_mapping["inspection"]["gate"] = [:location]
    @core_field_mapping["inspection"]["location"] = [:station_code]
    @core_field_mapping["inspection"]["ground handler"] = [:vendor]
    @core_field_mapping["inspection"]["regulation"] = [:reference]
    @core_field_mapping["inspection"]["description"] = [:instruction]
    @core_field_mapping["inspection"]["corrective actions"] = [:comment]
    @core_field_mapping["inspection"]["follow-up"] = [:final_comment]


    @core_field_mapping["sam"] = Hash.new
    @core_field_mapping["sam"]["auditor"] = [:responsible_user_id, :created_by_id, :approver_id]
    @core_field_mapping["sam"]["date of event"] = [:due_date]
    @core_field_mapping["sam"]["follow-up date"] = [:close_date]
    @core_field_mapping["sam"]["codeshare"] = [:audit_department]
    @core_field_mapping["sam"]["vendor"] = [:vendor]
    @core_field_mapping["sam"]["audit type"] = [:audit_type]
    @core_field_mapping["sam"]["location"] = [:location, :station_code]
    @core_field_mapping["sam"]["comments"] = [:comment]


    @core_field_mapping["station"] = Hash.new
    @core_field_mapping["station"]["auditor"] = [:responsible_user_id, :created_by_id]
    @core_field_mapping["station"]["audit type"] = [:audit_type]
    @core_field_mapping["station"]["location"] = [:location]
    @core_field_mapping["station"]["comments"] = [:comment]


    @core_field_mapping["planeside"] = Hash.new
    @core_field_mapping["planeside"]["auditor"] = [:responsible_user_id, :created_by_id]
    @core_field_mapping["planeside"]["date of event"] = [:due_date, :close_date]
    @core_field_mapping["planeside"]["codeshare"] = [:audit_department, :vendor]
    @core_field_mapping["planeside"]["audit type"] = [:audit_type]
    @core_field_mapping["planeside"]["location"] = [:location, :station_code]
    @core_field_mapping["planeside"]["comments"] = [:comment]


    @core_field_mapping["deice"] = Hash.new
    @core_field_mapping["deice"]["auditor"] = [:responsible_user_id, :created_by_id]
    @core_field_mapping["deice"]["date of event"] = [:due_date, :close_date]
    @core_field_mapping["deice"]["codeshare"] = [:audit_department, :vendor]
    @core_field_mapping["deice"]["audit type"] = [:audit_type]
    @core_field_mapping["deice"]["location"] = [:location, :station_code]
    @core_field_mapping["deice"]["comments"] = [:comment]


    @special_users = Hash.new
    @special_users["Albert Bauman"] = "Fred Bauman"
    @special_users["Jeff Lischak"] = "Jeffry Lischak"
    @special_users["YX"] = "Republic Airlines"
    @special_users["OO"] = "Skywest Airlines"
    @special_users["TSH"] = "TranStates Airlines"
    @special_users["AX"] = "TranStates Airlines"
    @special_users["YV"] = "Mesa Airlines"
    @special_users["C5"] = "CommutAir Airlines"
    @special_users["ZW"] = "AirWisconsin Airlines"
    @special_users["EV"] = "ExpressJet Airlines"
    @special_users["AA"] = "American Airlines"
    @special_users["American"] = "American Airlines"
    @special_users["Delta"] = "Delta Airlines"
    @special_users["United"] = "United Airlines"
    @special_users["TSA"] = "TSA User"
    @special_users["FAA"] = "FAA User"
    @special_users["N/A"] = ""
    @special_users["None Listed"] = ""
  end


  def start_audit_migration_process
    begin
      Dir.glob('lib/tasks/historical_rjet_audits/*.csv') do |csv_filename|
        headers = CSV.foreach("#{csv_filename}", encoding: 'iso-8859-1:utf-8').first
        # puts "\n\n #{csv_filename}"
        # puts headers
        CSV.foreach("#{csv_filename}", headers: true, encoding: 'iso-8859-1:utf-8') do |row|
          aud = Audit.new
          if csv_filename.downcase.include?("rsap")
            populate_audit(aud, headers, row, "rsap")
          elsif csv_filename.downcase.include?("findings")
            populate_audit(aud, headers, row, "finding")
          elsif csv_filename.downcase.include?("inspections")
            populate_audit(aud, headers, row, "inspection")
          elsif csv_filename.downcase.include?("enforcement")
            populate_audit(aud, headers, row, "enforcement")
          elsif csv_filename.downcase.include?("station")
            populate_audit(aud, headers, row, "station")
          elsif csv_filename.downcase.include?("extract")
            populate_audit(aud, headers, row, "sam")
          elsif csv_filename.downcase.include?("planeside")
            populate_audit(aud, headers, row, "planeside")
          elsif csv_filename.downcase.include?("deicing")
            populate_audit(aud, headers, row, "deice")
          end
        end
      end
    rescue => error
      @logger.info "[ERROR][START_PROCESS]: #{error.message}"
    end
  end


  def end_audit_migration_log
    @logger.info "Created #{@audit_created_count} audits."
    @logger.info "Failed to create #{@audit_failed_count} audits."
    @logger.info "Created #{@causes_created_count} causes."
    @logger.info "Created #{@user_created_count} users."
    @logger.info '########################################'
    @logger.info '#### MIGRATING OLD AUDITS COMPLETED ####'
    @logger.info "########################################\n\n"
  end


  def populate_audit(audit, headers, row, mode)
    if ["enforcement", "finding", "inspection"].include?(mode)
      audit.status = ""
      audit.audit_department = "Security"
      if mode == "finding"
        audit.audit_type = "Other – DHS Finding"
      elsif mode == "inspection"
        audit.audit_type = "Other – Station Reported"
      end
    else
      audit.status = "Closed"
      audit.department = "AO"
    end

    case mode
    when "rsap"
      audit.title = "RSAP Audit"
    when "sam"
      audit.title = "Airport Operations Observations Audit"
    when "station"
      audit.title = "Station Opening and Ground Handler Audit"
    when "planeside"
      audit.title = "Planeside Audit"
    when "deice"
      audit.title = "Deice/Anti-Icing Audit"
    end
    # puts mode
    populate_mapped_fields_and_save_records(audit, headers, row, mode)
  end


  def populate_mapped_fields_and_save_records(audit, headers, row, mode)
    map_hash = @core_field_mapping[mode]
    begin
      causes = []
      headers.each do |header|
        if header.to_s.strip.present?
          if map_hash.has_key?(header.to_s.strip.downcase)
            if map_hash[header.to_s.strip.downcase].is_a?(Array)
              map_hash[header.to_s.strip.downcase].each do |f|
                if f.to_s.include?("_date")
                  if ["enforcement", "finding", "inspection"].include?(mode)
                    value = Date.strptime(row[header].to_s, '%Y-%m-%d') rescue nil
                  else
                    value = Date.strptime(row[header].to_s, '%m/%d/%Y') rescue nil
                  end
                elsif f.to_s.include?("_id")
                  value = find_user_id(row[header].to_s.strip, mode) rescue nil
                elsif f.to_s == "department" && mode == "finding"
                  value = "DHS/TSA"
                else
                  value = row[header].to_s
                end
                set_audit_prop(audit, f.to_s, value)
              end
            end
          else
            value = row[header].to_s.strip rescue ""
            causes << Cause.new({owner_type: "Audit", category: mode, attr: header, value: value})
          end
        end
      end
      if audit.save
        @audit_created_count = @audit_created_count + 1
        causes.each do |cause|
          cause.owner_id = audit.id
          cause.save
          @causes_created_count = @causes_created_count + 1
        end
      end
    rescue => error
      @logger.info "[ERROR][POPULATE_MAPPED]: #{error.message}"
      @audit_failed_count = @audit_failed_count + 1
    end
  end


  def find_user_id(value, mode)
    value = map_to_full_name(value.strip)
    first_name = nil
    last_name = ""

    if value.strip.present?
      value.strip.split(" ").each do |part|
        if first_name.nil?
          first_name = part
        else
          last_name = last_name + part
        end
      end

      full_name = "#{first_name} #{last_name}"
      user = User.where(full_name: full_name).first rescue nil

      if user.nil?
        if last_name.present?
          username = "#{first_name[0]}#{first_name[1]}#{last_name}"
        else
          username = first_name
        end
        user = User.new({username: username, sso_id: username, first_name: first_name, last_name: last_name, full_name: full_name, level: "Staff", password: "Welcome2021!", disable: false})
        if user.save
          @user_created_count = @user_created_count + 1
          user.id
        else
          @logger.info "[ERROR][FIND_USER][#{mode.upcase}]: User with full name #{value} could not be created"
        end
      else
        user.id
      end
    else
      nil
    end
  end


  def map_to_full_name(value)
    if @special_users.has_key?(value)
      return @special_users[value]
    else
      return value
    end
  end


  def set_audit_prop(audit, prop_name, prop_value)
    audit.send("#{prop_name}=", prop_value)
  end
end
