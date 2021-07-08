namespace :sabre do
  require 'securerandom'
  @logger = Logger.new("log/sabre_data_transformation.log")

    task :update_sabre_data => [:environment] do |t, args|
      begin
        @logger.info '#####################################'
        @logger.info '###### UPDATING SABRE DATABASE ######'
        @logger.info '#####################################'
        @logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

        begin
          @prev_filename         = CONFIG::SABRE_FILE_IMPORT[:prev_filename]
          @destination_file_path = CONFIG::SABRE_FILE_IMPORT[:destination_file_path]
          @target_file_path      = CONFIG::SABRE_FILE_IMPORT[:target_file_path]

          @filename = "#{Time.now.in_time_zone('America/Los_Angeles').strftime("%Y%m%d")}-sabre.xml"
          # @filename = "20210707-sabre.xml"

          @target           = "#{@target_file_path}/#{@filename}"
          @destination      = "#{@destination_file_path}/#{@filename}"
          @prev_destination = "#{@destination_file_path}/#{@prev_filename}"

          unless system("cp #{@target} #{@destination}")
            @logger.info "[ERROR] #{DateTime.now}: #{@target} could not be fetched. Please check the file name and the path.\n"
            next #Abort
          end

          if File.exist?(@destination) && File.exist?(@prev_destination) && compare_file(@destination, @prev_destination)
            @logger.info "[INFO] Historical data was identical - no update necessary\n"
            next #Abort
          end

          flight_schedules = File.read(@destination).sub(/^\<\?.*\?\>$/, '').sub(/\<\/xml\>/, '')
        rescue => e
          @logger.info "#{e.inspect}"
          next #Abort
        end

        @total_sched_count = 0
        @records_saved = 0
        @records_rejected = 0
        @records_error = 0
        begin
          @logger.info "[INFO] #{DateTime.now}: Updating SABRE Database"
          Hash.from_xml(flight_schedules)["wbat_flight_schedule"]["flight_schedule"].each do |schedule|
            @total_sched_count = @total_sched_count + 1
            schedule_positions = schedule["user_name_list"]["position"]

            if schedule_positions.is_a?(Array)
              positions = schedule_positions.delete_if {|h| h['user_name'].nil?}
              if positions.present? && positions.size > 0
                positions.each do |pos|
                  emp_arr = Marshal.load(Marshal.dump(positions))
                  other_employees_arr = emp_arr.delete_if {|h| h['user_name'] == pos['user_name']}
                  saved = create_sabre_record(pos: pos, schedule: schedule, other_pos: other_employees_arr)
                  update_loggers(saved: saved)
                end
              else
                @records_error = @records_error + 1
                pos = {"user_name" => nil, "title" => nil}
                @logger.info "[ERROR]: Schedule does not have any valid employee(s) listed. The schedule is #{schedule}"
                saved = create_sabre_record(pos: pos, schedule: schedule, other_pos: nil)
                update_loggers(saved: saved)
              end
            elsif schedule_positions.is_a?(Hash)
              if schedule_positions['user_name'].nil?
                @records_error = @records_error + 1
                @logger.info "[POSSIBLE_ERROR]: Schedule does not have any valid employee(s) listed. The schedule is #{schedule}"
                saved = create_sabre_record(pos: schedule_positions, schedule: schedule, other_pos: nil)
              else
                saved = create_sabre_record(pos: schedule_positions, schedule: schedule, other_pos: nil)
              end
              update_loggers(saved: saved)
            else
              @logger.info "[ERROR]: Unknown data type encountered. Should be Array or Hash, but is neither."
            end
          end

          IO.copy_stream(@destination, @prev_destination) #Update Historical File

          @logger.info "TOTAL number of Flight Schedules: #{@total_sched_count}"
          @logger.info "Number of NEW Records Saved: #{@records_saved}"
          @logger.info "Number of Records REJECTED: #{@records_rejected}"
          @logger.info "Number of ERRONEOUS Schedules: #{@records_error}"
          @logger.info '####################################'
          @logger.info '###### SABRE UPDATE COMPLETED ######'
          @logger.info '####################################'
        rescue => err
          @logger.info "[ERROR]: #{err}"
          @logger.info '#################################'
          @logger.info '###### SABRE UPDATE FAILED ######'
          @logger.info '#################################'
        end
        @logger.info "SERVER DATE+TIME OF CONCLUSION: #{DateTime.now.strftime("%F %R")}\n\n"
      rescue => error
        location = 'sabre:update_sabre_data'
        subject = "Rake Task Error Encountered In #{location.upcase}"
        error_message = error.message
        NotifyMailer.notify_rake_errors(subject, error_message, location)
      end
    end


    def create_sabre_record(pos:, schedule:, other_pos:)
      begin
        other_employees = other_pos.present? ? other_pos.each.map{ |opos| opos['user_name'].present? ? opos['user_name'].strip : ""}.join(',') : nil
        sabre_record = Sabre.new({
          flight_date:       schedule['flight_date'].present? ? schedule['flight_date'].strip.to_date : nil,
          employee_number:   pos['user_name'].present? ? pos['user_name'].strip : nil,
          flight_number:     schedule['flight_number'].present? ? schedule['flight_number'].strip : nil,
          tail_number:       schedule['tail_number'].present? ? schedule['tail_number'].strip : nil,
          employee_title:    pos['title'].present? ? pos['title'].strip : nil,
          departure_airport: schedule['departure_airport'].present? ? schedule['departure_airport'].strip : nil,
          arrival_airport:   schedule['arrival_airport'].present? ? schedule['arrival_airport'].strip : nil,
          landing_airport:   schedule['landing_airport'].present? ? schedule['landing_airport'].strip : nil,
          other_employees:   other_employees.present? ? other_employees : nil
        })
        return sabre_record.save
      rescue => err
        @logger.info "[ERROR]: #{err}"
        @logger.info "[FAILED_RECORD_CREATION_SCHEDULE]: #{schedule}"
        return false
      end
    end


    def update_loggers(saved:)
      if !saved
        @records_rejected = @records_rejected + 1
      else
        @records_saved = @records_saved + 1
      end
    end
end
