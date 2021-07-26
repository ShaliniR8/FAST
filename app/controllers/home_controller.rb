class HomeController < ApplicationController
  include RiskMatricesHelper

  before_filter :login_required



  def index
    if session[:mode].blank?
      redirect_to choose_module_home_index_path
      return
    end

    @action = 'home'

    @start_date ||= Time.now - 1.month
    @end_date ||= Time.now
    @emp_groups = params[:emp_groups] ? params[:emp_groups] : nil
    @departments = params[:departments] ? params[:departments] : nil

    @notices = current_user.notices.where(status: 1).sort_by(&:created_at).reverse.first(6)

    prepare_data
    prepare_calendar
    prepare_risk_matrix
    prepare_special_risk_matrix

    @params = {
      advance_search: true,
      status: 'All',
      start_date: @start_date,
      end_date: @end_date,
      emp_groups: @emp_groups,
      departments: @departments,
    }

    respond_to do |format|
      format.html
      format.json {render :json => { :result => 'Possible error handled - Index'}}
    end
  end




  def prepare_data

    @notices = Notice.where(status: 1, users_id: current_user.id).reverse.first(6)

    @permissions = JSON.parse(session[:permissions])

    @colors = {
      "New"                   => '#4169E1',
      "Overdue"               => 'red',
      "Assigned"              => "#FF9912",
      "Open"                  => '#FFD700',
      "Under Review"          => '#EE9A00',
      "Awaiting Review"       => '#8F8F8F',
      "Pending Approval"      => '8F8F8F',
      "Pending Release"       => '#8F8F8F',
      "Pending Review"        => "#8F8F8F",
      "Transit to VP/Part 5"  => "black",
      "Linked"                => '#6959CD',
      "Evaluated"             => "#FF9912",
      "Rejected"              => "#DC143C",
      "Closed"                => "#008B00",
      "Completed"             => '#008B00',
    }
    @employee_groups = Template.select("distinct emp_group").map(&:emp_group).keep_if{|emp_grp| emp_grp.present?}
    @departments_list = CONFIG.custom_options['Departments']



    case session[:mode]
    when 'ASAP'

      @title = "Safety Reporting Dashboard"

      @templates = Template.where(name: (@permissions['submitter'] || []).compact)

      # ############################ SUBMISSIONS ########################
      submission_queries = []
      submission_queries << "(completed = true)"
      # template query
      if params[:emp_groups].present?
        templates = Template.where(name: (@permissions['full'] || []).compact, emp_group: params[:emp_group])
      else
        templates = Template.where(name: (@permissions['full'] || []).compact)
      end
      if templates.length > 0
        submission_queries << "(templates_id in (#{templates.map(&:id).join(',')}) OR user_id = #{current_user.id})"
      else
        submission_queries << "(user_id = #{current_user.id})"
      end


      # time range
      if @start_date.present? && @end_date.present?
        submission_queries << "event_date >= '#{@start_date.strftime('%Y-%m-%d %H:%M:%S')}'"
        submission_queries << "event_date <= '#{@end_date.strftime('%Y-%m-%d %H:%M:%S')}'"
      end

      @submissions = Submission.preload(:created_by, :template).where(submission_queries.join(' AND '))
      @grouped_submissions = @submissions.group_by{|x| x.template.name}.sort_by{|k, v| k}.to_h


      # ############################ RECORDS ########################
      record_queries = []

      # template query
      if params[:emp_groups].present?
        full_template = Template.where(name: (current_user.get_all_templates_hash[:full] || []).compact, emp_group: params[:emp_group])
        viewer_template = Template.where(name: (current_user.get_all_templates_hash[:viewer] || []).compact, emp_group: params[:emp_group])
      else
        full_template = Template.where(name: (current_user.get_all_templates_hash[:full] || []).compact)
        viewer_template = Template.where(name: (current_user.get_all_templates_hash[:viewer] || []).compact)
      end
      template_query = ["(users_id = #{current_user.id})"]
      if full_template.length > 0
        template_query << "(templates_id in (#{full_template.map(&:id).join(',')}))"
      end
      if viewer_template.length > 0
        template_query << "(templates_id in (#{viewer_template.map(&:id).join(',')}) AND viewer_access = true)"
      end
      record_queries << "(#{template_query.join(' OR ')})"

      # time range
      if @start_date.present? && @end_date.present?
        record_queries << "event_date >= '#{@start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
        record_queries << "event_date <= '#{@end_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
      end

      @records = Record.preload(:created_by, :template, :report).where(record_queries.join(' AND '))
      @grouped_records = @records.group_by(&:status).sort_by{|k, v| k}.to_h
      @records_scheduled_completion_date = get_avg_completion_date(@records)


      # ############################ REPORTS ########################
      @reports = @records.map(&:report).flatten.compact.uniq
      @grouped_reports = @reports.group_by{|x| x.status}
      @reports_scheduled_completion_date = get_avg_completion_date(@reports)


      # ############################ CORRECTIVE ACTIONS ########################
      corrective_action_queries = []
      # time range
      if @start_date.present? && @end_date.present?
        corrective_action_queries << "due_date >= '#{@start_date.strftime('%Y-%m-%d %H:%M:%S')}'"
        corrective_action_queries << "due_date <= '#{@end_date.strftime('%Y-%m-%d %H:%M:%S')}'"
      end
      if params[:emp_groups].present?
        corrective_action_queries << "department = '#{params[:emp_group]}'"
      end
      @corrective_actions = CorrectiveAction.where(corrective_action_queries.join(' AND '))
      @grouped_corrective_actions = @corrective_actions.group_by(&:status)
      @corrective_actions_scheduled_completion_date = get_avg_completion_date(@corrective_actions)


    when 'SMS IM'
      @title = "SMS IM Dashboard"

      frameworks=FrameworkIm.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @frameworks=frameworks.group_by{|x| x.status}
      if (temp=frameworks.select{|x| x.overdue}).present?
        @frameworks["Overdue"]=temp
      end
      Rails.logger.debug "filtered_frameworks=#{@frameworks}"

      vps=VpIm.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @vps=vps.group_by {|x| x.status}
      if (temp=vps.select{|x| x.overdue}).present?
        @vps["Overdue"]=temp
      end

      jobaids=JobAid.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @jobaids=jobaids.group_by {|x| x.status}
      if (temp=jobaids.select{|x| x.overdue}).present?
        @jobaids["Overdue"]=temp
      end

      fp=FrameworkImPackage.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @fps=@fp=fp.group_by{|x| x.status}

      vpp=VpImPackage.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @vpps=@vpp=vpp.group_by{|x| x.status}

      jap=JobAidPackage.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @japs=@jap=jap.group_by{|x| x.status}

    when 'SMS'
      @title = "Safety Assurance Dashboard"

      if current_user.has_access("audit","index")
        @audits = Audit.regulars.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
        @grouped_audits = @audits.group_by{|x| x.status}
        if (temp = @audits.select{|x| x.overdue}).present?
          @grouped_audits["Overdue"] = temp
        end
      end
      if current_user.has_access("findings","index")
        @findings = Finding.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
        @grouped_findings = @findings.group_by{|x| x.status}
        if (temp = @findings.select{|x| x.overdue}).present?
          @grouped_findings["Overdue"] = temp
        end
      end
      if current_user.has_access("sms_actions","index")
        @corrective_actions = SmsAction.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_corrective_actions = @corrective_actions.group_by{|x| x.status}
        if (temp = @corrective_actions.select{|x| x.overdue}).present?
          @grouped_corrective_actions["Overdue"] = temp
        end
      end
      if current_user.has_access("inspections","index")
        @inspections = Inspection.regulars.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_inspections = @inspections.group_by{|x| x.status}
        if (temp = @inspections.select{|x| x.overdue}).present?
           @grouped_inspections["Overdue"] = temp
        end
      end
      if current_user.has_access("evaluations","index")
        @evaluations = Evaluation.regulars.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_evaluations = @evaluations.group_by{|x| x.status}
        if (temp = @evaluations.select{|x| x.overdue}).present?
          @grouped_evaluations["Overdue"] = temp
        end
      end
      if current_user.has_access("recommendations","index")
        @recommendations = Recommendation.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_recommendations = @recommendations.group_by{|x| x.status}
        if (temp = @recommendations.select{|x| x.overdue}).present?
          @grouped_recommendations["Overdue"] = temp
        end
      end
      if current_user.has_access("investigations","index")
        @investigations = Investigation.regulars.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_investigations = @investigations.group_by{|x| x.status}
        if (temp = @investigations.select{|x| x.overdue}).present?
          @grouped_investigations["Overdue"] = temp
        end
      end


    when 'SRM'
      @title = "SRA (SRM) Dashboard"

      @sras = Sra.within_timerange(@start_date, @end_date).by_departments(params[:departments]).sort{|x,y| status_index(x) <=> status_index(y)}
      @grouped_sras = @sras.group_by{|x| x.status}
      if (temp = @sras.select{|x| x.overdue}).present?
        @grouped_sras["Overdue"] = temp
      end

      @hazards = Hazard.within_timerange(@start_date, @end_date).by_departments(params[:departments]).sort{|x,y| status_index(x) <=> status_index(y)}
      @grouped_hazards = @hazards.group_by{|x| x.status}
      if (temp = @hazards.select{|x| x.overdue}).present?
        @grouped_hazards['Overdue'] = temp
      end

      @risk_controls = RiskControl.within_timerange(@start_date, @end_date).by_departments(params[:departments]).sort{|x,y| status_index(x) <=> status_index(y)}
      @grouped_risk_controls = @risk_controls.group_by{|x| x.status}
      if (temp = @risk_controls.select{|x| x.overdue}).present?
        @grouped_risk_controls['Overdue'] = temp
      end

      @safety_plans = SafetyPlan.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
      @grouped_safety_plans = @safety_plans.group_by{|x| x.status}
    end
  end


  def prepare_calendar
    @calendar_entries = []
    current_user_id = session[:simulated_id] || session[:user_id]


    if session[:mode] == "SMS"

      objects = ['Audit', 'Inspection', 'Evaluation', 'Investigation', 'Finding', 'SmsAction', 'Recommendation']
      objects.each do |x|
        records = Object.const_get(x).where(status: 'Assigned', responsible_user_id: current_user_id)
        records << Object.const_get(x).where(status: 'Pending Approval', approver_id: current_user_id)
        records.flatten.each do |record|
          x = x == 'SmsAction' ? 'CorrectiveAction' : x
          if (record.get_completion_date.present? rescue false)
            @calendar_entries.push({
              :url => "#{records.table_name}/#{record.id}",
              :start => record.get_completion_date,
              :color => (record.overdue ? "lightcoral" : "skyblue"),
              :textColor => "darkslategrey",
              :title => "#{x.titleize} ##{record.id}: #{record.title} (#{record.status})"
            })
          end
        end
      end


      Verification.where(:status => 'New').each do |x|
        x.get_all_validators.each do |validator|
          if validator == current_user

            next if x.owner.class.name == 'CorrectiveAction'

            owner_class = x.owner.class.name == 'SmsAction' ? 'CorrectiveAction' : x.owner.class.name
            @calendar_entries.push({
              :url => "#{x.owner.class.table_name}/#{x.owner_id}",
              :start => x.verify_date,
              :color => 'skyblue',
              :textColor => "darkslategrey",
              :title => "#{owner_class.titleize} ##{x.owner.id}: Verification required"
            })

          end
        end
      end


    elsif session[:mode] == "ASAP"
      if current_user.has_access("meeting", "index")
        meetings = Meeting.preload(:host, :invitations).where("status != ? and type is null", "Closed")
        meetings = meetings.select{|x| x.has_user(current_user)}
        meetings.each do |meeting|
          @calendar_entries.push({
            :url => meeting_path(meeting),
            :start => meeting.get_time("meeting_start"),
            :end => meeting.get_time("meeting_end"),
            :title => "#{meeting.meeting_type} Meeting \##{meeting.id}",
            :color => "khaki",
            :textColor => "darkslategrey",
            :description => meeting.get_tooltip
          })
        end
      end

      if current_user.has_access("submissions", "index")
        @submissions.each do |a|
          @calendar_entries.push({
            :url => submission_path(a),
            :start => a.get_date,
            :title => "Submission: #{a.template.name} ##{a.send(CONFIG.sr::HIERARCHY[:objects]['Submission'][:fields][:id][:field])}",
            :textColor => "darkslategrey",
            :description => "<b>#{a.template.name} ##{a.send(CONFIG.sr::HIERARCHY[:objects]['Submission'][:fields][:id][:field])}</b>: #{a.description}",
            :color => group_to_color(a.template.emp_group)
          }) if a.get_date.present?
        end
      end

      if current_user.has_access("records", "index")
        @records.each do |a|
          title_status = a.status == 'Closed' ? "#{a.template.name} ##{a.get_id} (Closed)" : "#{a.template.name} ##{a.get_id}"
          @calendar_entries.push({
            :url => record_path(a),
            :start => a.get_date,
            :title => title_status,
            :textColor => "darkslategrey",
            :description => "Report: <b>#{a.template.name} ##{a.get_id}</b>: #{a.description}",
            :color => group_to_color(a.template.emp_group)
          }) if a.get_date.present?
        end
      end

      objects = ['CorrectiveAction']
      objects.each do |x|
        records = Object.const_get(x).where(status: 'Assigned', responsible_user_id: current_user_id)
        records << Object.const_get(x).where(status: 'Pending Approval', approver_id: current_user_id)
        records.flatten.each do |record|
          if (record.due_date.present? rescue false)
            @calendar_entries.push({
              :url => "#{records.table_name}/#{record.id}",
              :start => record.due_date,
              :color => "lightcoral",
              :textColor => "darkslategrey",
              :title => "#{x.titleize} ##{record.id}: (#{record.status})"
            })
          end
        end
      end


    elsif session[:mode] == "SRM"

      sras = Sra.where(status: 'Assigned', responsible_user_id: current_user_id)
      sras << Sra.where(status: 'Pending Review', reviewer_id: current_user_id)
      sras << Sra.where(status: 'Pending Approval', approver_id: current_user_id)
      sras.flatten.each do |a|
        if a.due_date.present?
          @calendar_entries.push({
            :url => sra_path(a),
            :start => a.get_due_date,
            :color => (a.overdue ? "lightcoral" : "skyblue"),
            :textColor => "darkslategrey",
            :title=>"SRA ##{a.id}: "+ a.title + " (#{a.status})"
          })
        end
      end

      risk_controls = RiskControl.where(status: 'Assigned', responsible_user_id: current_user_id)
      risk_controls << RiskControl.where(status: 'Pending Approval', approver_id: current_user_id)
      risk_controls.flatten.each do |a|
        if a.due_date.present?
          @calendar_entries.push({
            :url => risk_control_path(a),
            :start => a.get_due_date,
            :color => (a.overdue ? "lightcoral" : "skyblue"),
            :textColor => "darkslategrey",
            :title => "Risk Control ##{a.id}: " + a.title + " (#{a.status})"
          })
        end
      end

      hazards = Hazard.where(status: 'Assigned', responsible_user_id: current_user_id)
      hazards << Hazard.where(status: 'Pending Approval', approver_id: current_user_id)
      hazards.flatten.each do |a|
        if a.due_date.present?
          @calendar_entries.push({
            :url => hazard_path(a),
            :start => a.get_due_date,
            :color => (a.overdue ? "lightcoral" : "skyblue"),
            :textColor => "darkslategrey",
            :title => "Hazard ##{a.id}: " + a.title + " (#{a.status})"
          })
        end
      end


      if current_user.has_access("srm_meeting","index")
        meetings = SrmMeeting.where("status!=?","Closed")
        meetings = meetings.select{|x| x.has_user(current_user)}
        meetings.each do |a|
          @calendar_entries.push({
            :url=>srm_meeting_path(a),
            :start=>a.get_time("meeting_start"),
            :end=>a.get_time("meeting_end"),
            :title=>"SRM Meeting \##{a.id}",
            :color => "khaki",
            :textColor => "darkslategrey",
            :description=>a.get_tooltip})
        end
      end

      Verification.where(:status => 'New').each do |x|
        x.get_all_validators.each do |validator|
          if validator == current_user

            next if ['SmsAction', 'CorrectiveAction'].include? x.owner.class.name

            @calendar_entries.push({
              :url => "#{x.owner.class.table_name}/#{x.owner_id}",
              :start => x.verify_date,
              :color => 'skyblue',
              :textColor => "darkslategrey",
              :title => "#{x.owner.class.name.titleize} ##{x.owner.id}: Verification required"
            })
          end
        end
      end


    elsif session[:mode] == "SMS IM"
      if current_user.has_access("sms_meeting","index")
        meetings = Meeting.where("status!=? and type is not ? and type != ?",
          "Closed",
          nil,
          "SrmMeeting")
        meetings = meetings.select{|x| x.has_user(current_user)}
        meetings.each do |a|
          @calendar_entries.push({
            :url => sms_meeting_path(a),
            :start => a.get_time("meeting_start"),
            :end => a.get_time("meeting_end"),
            :title => "SMS IM Meeting \##{a.id}",
            :color => "khaki",
            :textColor => "darkslategrey",
            :description => a.get_tooltip
          })
        end
      end
      if current_user.has_access('ims','index')
        ims = Im.where("status!=?","Completed")
        ims = ims.select{|x| x.lead_evaluator == current_user_id}
        ims.each do |a|
          if a.completion_date.present?
            @calendar_entries.push({
              :url => im_path(a),
              :start => a.completion_date,
              :color => (a.overdue ? "lightcoral" : "skyblue"),
              :title => "#{a.class.display_name} : " + a.title + " (Due)"
            })
          end
        end
      end
    end
  end


  def prepare_special_risk_matrix
    special_matrix
    row_sz = @risk_table[:row_header].size
    col_sz = @risk_table[:column_header].size

    if row_sz > col_sz
      col_sz = row_sz
    else
      row_sz = col_sz
    end

    @frequency = [
      'FREQUENT >4.00',
      'PROBABLE 4.00~3.01',
      'OCCASIONAL 3.00~2.01',
      'REMOTE 2.01~1.00',
      'IMPROBABLE <1.00'
    ]
    @severity = [
      'CATASTROPHIC, >4.00',
      'CRITICAL 4.00~2.51',
      'MARGINAL 2.50~1.01',
      'MINOR <=1.0'
    ]

    # Safety Assurance
    if session[:mode] == "SMS"
      # Findings
      @finding_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @finding_after_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      Finding.within_timerange(@start_date, @end_date).each do |finding|
        if finding.severity.present? && finding.likelihood_index.present?
          @finding_matrix[finding.severity.to_i][finding.likelihood_index] =
            @finding_matrix[finding.severity.to_i][finding.likelihood_index] + 1
        end
        if finding.severity_after.present? && finding.likelihood_after_index.present?
          @finding_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index] =
            @finding_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index] + 1
        end
      end
      # Investigations
      @inv_after_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @inv_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      Investigation.within_timerange(@start_date, @end_date).each do |finding|
        if finding.severity.present? && finding.likelihood_index.present?
          @inv_matrix[finding.severity.to_i][finding.likelihood_index] =
            @inv_matrix[finding.severity.to_i][finding.likelihood_index] + 1
        end
        if finding.severity_after.present? && finding.likelihood_after_index.present?
          @inv_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index] =
            @inv_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index] + 1
        end
      end
      @matrix_title = "#{I18n.t("core.risk.baseline.title")} Risk Analysis: Findings"
      @after_title = "#{I18n.t("core.risk.mitigated.title")} Risk Analysis: Findings"

      # SmsActions
      @car_after_matrix = Array.new(row_sz){Array.new(col_sz, 0)}
      @car_matrix = Array.new(row_sz){Array.new(col_sz, 0)}
      SmsAction.within_timerange(@start_date, @end_date).each do |x|
        if x.severity.present? && x.likelihood_index.present?
          @car_matrix[x.severity.to_i][x.likelihood_index] =
            @car_matrix[x.severity.to_i][x.likelihood_index] + 1
        end
        if x.severity_after.present? && x.likelihood_after_index.present?
          @car_after_matrix[x.severity_after.to_i][x.likelihood_after_index] =
            @car_after_matrix[x.severity_after.to_i][x.likelihood_after_index] + 1
        end
      end


    # Safety Reporting Module
    elsif session[:mode] == "ASAP"
      @record_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @record_after_matrix = Array.new(row_sz){Array.new(col_sz,0)}

      @records.each do |record|
        if record.severity_after.present? && record.likelihood_after_index.present?
          @record_after_matrix[record.severity_after.to_i][record.likelihood_after_index] =
            @record_after_matrix[record.severity_after.to_i][record.likelihood_after_index] + 1
        end
        if record.severity.present? && record.likelihood_index.present?
          @record_matrix[record.severity.to_i][record.likelihood_index] =
            @record_matrix[record.severity.to_i][record.likelihood_index] + 1
        end
      end

      @report_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @report_after_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @reports.each do |report|
        if report.severity_after.present? && report.likelihood_after_index.present?
          @report_after_matrix[report.severity_after.to_i][report.likelihood_after_index] =
            @report_after_matrix[report.severity_after.to_i][report.likelihood_after_index] + 1
        end
        if report.severity.present? && report.likelihood_index.present?
          @report_matrix[report.severity.to_i][report.likelihood_index] =
            @report_matrix[report.severity.to_i][report.likelihood_index] + 1
        end
      end
      @matrix_title = "#{I18n.t("core.risk.baseline.title")} Risk Analysis: Reports"
      @after_title = "#{I18n.t("core.risk.mitigated.title")} Risk Analysis: Reports"

    # Safety Risk Management
    else

      @hazard_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @hazard_after_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      Hazard.within_timerange(@start_date, @end_date).by_departments(params[:departments]).each do |hazard|
        if hazard.severity_after.present? && hazard.likelihood_after_index.present?
          @hazard_after_matrix[hazard.severity_after.to_i][hazard.likelihood_after_index] =
            @hazard_after_matrix[hazard.severity_after.to_i][hazard.likelihood_after_index] + 1
        end
        if hazard.severity.present? && hazard.likelihood_index.present?
          @hazard_matrix[hazard.severity.to_i][hazard.likelihood_index] =
            @hazard_matrix[hazard.severity.to_i][hazard.likelihood_index] + 1
        end
      end
      @sra_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      @sra_after_matrix = Array.new(row_sz){Array.new(col_sz,0)}
      Sra.within_timerange(@start_date, @end_date).by_departments(params[:departments]).each do |sra|
        if sra.severity_after.present? && sra.likelihood_after_index.present?
          @sra_after_matrix[sra.severity_after.to_i][sra.likelihood_after_index] =
            @sra_after_matrix[sra.severity_after.to_i][sra.likelihood_after_index] + 1
        end
        if sra.severity.present? && sra.likelihood_index.present?
          @sra_matrix[sra.severity.to_i][sra.likelihood_index] =
            @sra_matrix[sra.severity.to_i][sra.likelihood_index] + 1
        end
      end
      @matrix_title = "#{I18n.t("core.risk.baseline.title")} Risk Analysis: Hazards"
      @after_title = "#{I18n.t("core.risk.mitigated.title")} Risk Analysis: Hazards"
    end
  end


  def prepare_templates
    templates = current_user.get_all_submitter_templates
    @templates = Template.where(:name => templates)
    @templates.keep_if{|x|
      (current_user.has_template_access(x.name).include? "full") ||
      (current_user.has_template_access(x.name).include? "submitter")}
      .sort_by!{|x| x.name}
    @orm_templates = OrmTemplate.order(:name).all
  end


  def choose_module
    session[:mode] = ""
    if params[:mode].present?
      session[:mode] = params[:mode]
      redirect_to root_url
      return
    end
    accessible_modules = current_user.accessible_modules
    case accessible_modules.length
    when 1
      single_landing_page = module_display_to_mode(accessible_modules.first)
      redirect_to choose_module_home_index_path(:mode => single_landing_page)
      return
    when 2
      @size="col-xs-12 col-sm-6"
    when 3
      @size="col-xs-12 col-sm-4"
    when 4
      @size="col-xs-12 col-sm-6 col-md-3"
    end

    respond_to do |format|
      format.html
      format.json {render :json => { :result => 'Possible error handled - ChooseModule'}}
    end
  end


  def prepare_risk_matrix
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    risk_matrix_initializer
    create_risk_matrices_with_num_of_occurrences
  end


  def update_analytics_timerange
    @end_date = Time.zone.now.end_of_day
    case params[:time_range]
    when "last_year"
      @start_date = (Time.zone.now - 1.years).beginning_of_day
    when "last_month"
      @start_date = (Time.zone.now - 1.months).beginning_of_day
    when "last_week"
      @start_date = (Time.zone.now - 1.weeks).beginning_of_day
    when "last_day"
      @start_date = (Time.zone.now - 1.days).beginning_of_day
    when "custom"
      @start_date = Time.zone.parse(params[:start_date])
      @end_date = Time.zone.parse(params[:end_date])
    else
      @start_date = @end_date = nil
    end
    @emp_groups = params[:emp_groups] ? params[:emp_groups] : nil
    @departments = params[:departments] ? params[:departments] : nil

    @params = {
      advance_search: true,
      status: 'All',
      start_date: @start_date,
      end_date: @end_date,
      emp_groups: @emp_groups,
      departments: @departments,
    }

    prepare_data
    prepare_calendar
    prepare_risk_matrix
  end


  def prepare_verification_calendar(object_name)
    @table = Object.const_get(object_name)
    @events = @table.where(
      :users_id => current_user.id,
      :status => "New")
    events = []
    @events.each do |e|
      events.push({
        :url => "#{e.owner.class.table_name}/#{e.owner.id}",
        :start => e.verify_date,
        :color => 'tomato',
        :textColor => "darkslategrey",
        :title => e.owner.class.name + ": " + e.owner.title + " (Verification Required)"
      })
    end
    events
  end



  def advanced_search
    @table = Object.const_get(params[:table])
    @path = eval("#{@table.table_name}_path")
    meta_field_args = ['show']
    meta_field_args.push('admin') if current_user.admin?
    @terms = @table.get_meta_fields(*meta_field_args).keep_if{|x| x[:field].present?}
    @status = params[:status]
    render :partial => '/shared/advanced_search'
  end


  private


  def get_avg_completion_date(records)
    sum = 0
    count = 0
    records.each do |record|
      next if !['Closed', 'Completed'].include?(record.status) # skip if record is not completed
      open_date = record.open_date rescue record.created_at    # use created_at date if open date is null
      close_date = record.close_date rescue record.updated_at  # use updated_at date if close date is null
      open_date ||= record.created_at
      close_date ||= record.updated_at
      sum += (close_date.to_date - open_date.to_date).to_i rescue next # skip if error
      count = count + 1
    end
    (sum.to_f / count).round(1) rescue 0
  end


end
