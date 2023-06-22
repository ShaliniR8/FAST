# Steps: Create Dummy User. Check username from code below. Configure airline's SR Config file with correct template IDs
task :deidentify_reports_and_submissions => :environment do

  @log = Logger.new("log/daily_didentify_#{Rails.env}.log")
  @log.level = Logger::INFO
  @log.datetime_format = "%Y-%m-%d %H:%M:%S"
  @log.info "======================================================"

  look_back_years = 2
  first_time = false
  # first_time = true
  dummy_user = User.where({username: "prdg_deid_user"}).first
  dummy_value = "#########"

  begin
    start_date = nil
    end_date = nil

    if first_time.present?
      start_date = Date.today - 10.years
      end_date = Date.today - look_back_years.years
    else
      start_date = Date.today - 2.years - 1.day
      end_date = Date.today - 2.years
    end

    @log.info "Start Date: #{start_date}"
    @log.info "End Date: #{end_date}"

    records = Record.where({templates_id: CONFIG.sr::GENERAL[:deidentifying_templates], created_at: start_date.beginning_of_day..end_date.end_of_day})
    # records = Record.where({templates_id: CONFIG.sr::GENERAL[:deidentifying_templates], event_date: start_date.beginning_of_day..end_date.end_of_day})

    if records.present?
      record_fields = records.map(&:record_fields).flatten.keep_if{|rf| rf.field.present? && !rf.field.print.present? && rf.value.present?}
      record_transactions = Transaction.where({owner_type: 'Record', owner_id: records.map(&:id), users_id: records.map(&:users_id)})
      submissions = records.map(&:submission).compact
      submission_fields = submissions.map(&:submission_fields).flatten.keep_if{|sf| sf.field.present? && !sf.field.print.present? && sf.value.present?}
      submission_transactions = Transaction.where({owner_type: 'Submission', owner_id: submissions.map(&:id), users_id: submissions.map(&:user_id)})
      events = records.map(&:report).flatten.compact.uniq
      corrective_actions = records.map(&:corrective_actions).flatten.compact
      attachments = (records.map(&:attachments) + submissions.map(&:attachments)).flatten.compact.uniq

      @log.info "Records to De-Identify: #{records.map(&:id)}"
      @log.info "De-Identifying #{records.size} records, #{record_fields.size} record_fields, #{record_transactions.size} record transactions, #{submissions.size} submissions, #{submission_fields.size} submission_fields, #{submission_transactions.size} submission transactions, #{events.size} events, #{corrective_actions.size} corrective actions and deleting #{attachments.size} attachments"

      records.map{|r| r.update_attributes({users_id: dummy_user.id, event_date: (r.event_date.in_time_zone(CONFIG::GENERAL[:time_zone]).beginning_of_month)})}
      record_fields.map{|rf| rf.update_attributes({value: dummy_value})}
      record_transactions.map{|rt| rt.update_attributes({users_id: dummy_user.id})}
      submissions.map{|s| s.update_attributes({user_id: dummy_user.id, event_date: (s.event_date.in_time_zone(CONFIG::GENERAL[:time_zone]).beginning_of_month)})}
      submission_fields.map{|sf| sf.update_attributes({value: dummy_value})}
      submission_transactions.map{|st| st.update_attributes({users_id: dummy_user.id})}
      events.map{|e| e.update_attributes({event_date: (e.event_date.in_time_zone(CONFIG::GENERAL[:time_zone]).beginning_of_month)})}
      corrective_actions.map{|ca| ca.update_attributes({due_date: (ca.due_date.present? ? (ca.due_date.beginning_of_month) : nil),
                                                        opened_date: (ca.opened_date.present? ? (ca.opened_date.beginning_of_month) : nil),
                                                        assigned_date: (ca.assigned_date.present? ? (ca.assigned_date.beginning_of_month) : nil),
                                                        decision_date: (ca.decision_date.present? ? (ca.decision_date.beginning_of_month) : nil),
                                                        revised_due_date: (ca.revised_due_date.present? ? (ca.revised_due_date.beginning_of_month) : nil),
                                                        close_date: (ca.close_date.present? ? (ca.close_date.beginning_of_month) : nil)})}

      attachments.each do |att|
        cmd = "rm -rf public/uploads/attachment/name/#{att.id}"
        system cmd
      end
      # attachments.map{|a| a.update_attributes({attachment_id: a.owner_id, owner_id: nil})} # dissociate attachment from record but keep id within attachment_id in case we need to restore. No files will actually be deleted.
      attachments.map(&:delete) # deletes object. destroy will throw session error. Using shell commands to actually delete attachment
    else
      @log.info "No Reports to De-Identify"
    end

  rescue => error
    @log.info "[#{Time.now}] ERROR: #{error}"
    @log.info "[#{Time.now}] ERROR_MESSAGE: #{error.message}"
    @log.info "[#{Time.now}] ERROR_STACK_TRACE: #{error.backtrace}"
  end

end
