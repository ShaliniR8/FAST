class HomeController < ApplicationController


  before_filter :login_required


  def index
    if session[:mode].blank?
      redirect_to choose_module_home_index_path
      return
    end
    @action = "home"
    prepare_analytics
    prepare_calendar
    prepare_special_risk_matrix
    prepare_risk_matrix
    prepare_templates
  end



  def prepare_special_risk_matrix
    special_matrix
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
      @finding_matrix = Array.new(5){Array.new(5,0)}
      @finding_after_matrix = Array.new(5){Array.new(5,0)}
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
      @inv_after_matrix = Array.new(5){Array.new(5,0)}
      @inv_matrix = Array.new(5){Array.new(5,0)}
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
      @matrix_title = "Baseline Risk Analysis: Findings"
      @after_title = "Substitute Risk Analysis: Findings"

      # SmsActions
      @car_after_matrix = Array.new(5){Array.new(5, 0)}
      @car_matrix = Array.new(5){Array.new(5, 0)}
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
      @record_matrix = Array.new(5){Array.new(5,0)}
      @record_after_matrix = Array.new(5){Array.new(5,0)}

      Record.can_be_accessed(current_user)
        .within_timerange(@start_date, @end_date)
        .by_emp_groups(params[:emp_groups])
        .each do |record|
        if record.severity_after.present? && record.likelihood_after_index.present?
          @record_after_matrix[record.severity_after.to_i][record.likelihood_after_index] =
            @record_after_matrix[record.severity_after.to_i][record.likelihood_after_index] + 1
        end
        if record.severity.present? && record.likelihood_index.present?
          @record_matrix[record.severity.to_i][record.likelihood_index] =
            @record_matrix[record.severity.to_i][record.likelihood_index] + 1
        end
      end
      @report_matrix = Array.new(5){Array.new(5,0)}
      @report_after_matrix = Array.new(5){Array.new(5,0)}
      Report.within_timerange(@start_date, @end_date).each do |report|
        #if display_in_table(report)
          if report.severity_after.present? && report.likelihood_after_index.present?
            @report_after_matrix[report.severity_after.to_i][report.likelihood_after_index] =
              @report_after_matrix[report.severity_after.to_i][report.likelihood_after_index] + 1
          end
          if report.severity.present? && report.likelihood_index.present?
            @report_matrix[report.severity.to_i][report.likelihood_index] =
              @report_matrix[report.severity.to_i][report.likelihood_index] + 1
          end
        #end
      end
      @matrix_title = "Baseline Risk Analysis: Reports"
      @after_title = "Substitute Risk Analysis: Reports"

    # Safety Risk Management
    else

      if false
      @hazard_matrix = Array.new(5){Array.new(5,0)}
      @hazard_after_matrix = Array.new(5){Array.new(5,0)}
      Hazard.within_timerange(@start_date, @end_date).each do |hazard|
        if hazard.severity_after.present? && hazard.likelihood_after_index.present?
          @hazard_after_matrix[hazard.severity_after.to_i][hazard.likelihood_after_index] =
            @hazard_after_matrix[hazard.severity_after.to_i][hazard.likelihood_after_index] + 1
        end
        if hazard.severity.present? && hazard.likelihood_index.present?
          @hazard_matrix[hazard.severity.to_i][hazard.likelihood_index] =
            @hazard_matrix[hazard.severity.to_i][hazard.likelihood_index] + 1
        end
      end
      @sra_matrix = Array.new(5){Array.new(5,0)}
      @sra_after_matrix = Array.new(5){Array.new(5,0)}
      Sra.within_timerange(@start_date, @end_date).each do |sra|
        if sra.severity_after.present? && sra.likelihood_after_index.present?
          @sra_after_matrix[sra.severity_after.to_i][sra.likelihood_after_index] =
            @sra_after_matrix[sra.severity_after.to_i][sra.likelihood_after_index] + 1
        end
        if sra.severity.present? && sra.likelihood_index.present?
          @sra_matrix[sra.severity.to_i][sra.likelihood_index] =
            @sra_matrix[sra.severity.to_i][sra.likelihood_index] + 1
        end
      end
      @matrix_title = "Baseline Risk Analysis: Hazards"
      @after_title = "Substitute Risk Analysis: Hazards"
      end
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
    when 2
      @size="col-xs-12 col-sm-6"
    when 3
      @size="col-xs-12 col-sm-4"
    when 4
      @size="col-xs-12 col-sm-6 col-md-3"
    end
  end



  def prepare_risk_matrix
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    risk_matrix_initializer

    # Safety Assurance Module
    if session[:mode] == "SMS"
      # Findings
      @finding_matrix = Array.new(5){Array.new(5,0)}
      @finding_after_matrix = Array.new(5){Array.new(5,0)}
      Finding.within_timerange(@start_date, @end_date).each do |finding|
        if finding.severity.present? && finding.likelihood_index.present?
          @finding_matrix[finding.severity.to_i][finding.likelihood_index] =
            @finding_matrix[finding.severity.to_i][finding.likelihood_index]+1
        end
        if finding.severity_after.present? && finding.likelihood_after_index.present?
          @finding_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index] =
            @finding_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index]+1
        end
      end
      Rails.logger.debug "finding_after_matrix=#{@finding_after_matrix.inspect}"

      # Investigations
      @inv_after_matrix = Array.new(5){Array.new(5,0)}
      @inv_matrix = Array.new(5){Array.new(5,0)}
      Investigation.within_timerange(@start_date, @end_date).each do |finding|
        if finding.severity.present? && finding.likelihood_index.present?
          @inv_matrix[finding.severity.to_i][finding.likelihood_index] =
            @inv_matrix[finding.severity.to_i][finding.likelihood_index]+1
        end
        if finding.severity_after.present? && finding.likelihood_after_index.present?
          @inv_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index] =
            @inv_after_matrix[finding.severity_after.to_i][finding.likelihood_after_index]+1
        end
      end

      # Sms Actions
      @car_after_matrix=Array.new(5){Array.new(5,0)}
      @car_matrix=Array.new(5){Array.new(5,0)}
      SmsAction.within_timerange(@start_date, @end_date).each do |car|
        if car.severity.present? && car.likelihood_index.present?
          @car_matrix[car.severity.to_i][car.likelihood_index] =
            @car_matrix[car.severity.to_i][car.likelihood_index]+1
        end
        if car.severity_after.present? && car.likelihood_after_index.present?
          @car_after_matrix[car.severity_after.to_i][car.likelihood_after_index] =
            @car_after_matrix[car.severity_after.to_i][car.likelihood_after_index]+1
        end
      end

      @matrix_title="Baseline Risk Analysis: Findings"
      @after_title="Substitute Risk Analysis: Findings"


    # Safety Reporting Module
    elsif session[:mode] == "ASAP"
      @record_matrix = Array.new(5){Array.new(5,0)}
      @record_after_matrix = Array.new(5){Array.new(5,0)}
      Record.can_be_accessed(current_user)
        .within_timerange(@start_date, @end_date)
        .by_emp_groups(params[:emp_groups])
        .each do |record|
        #if record.to_show
          if record.severity_after.present? && record.likelihood_after_index.present?
            @record_after_matrix[record.severity_after.to_i][record.likelihood_after_index] =
              @record_after_matrix[record.severity_after.to_i][record.likelihood_after_index]+1
          end
          if record.severity.present? && record.likelihood_index.present?
            @record_matrix[record.severity.to_i][record.likelihood_index] =
              @record_matrix[record.severity.to_i][record.likelihood_index]+1
          end
        #end
      end
      @report_matrix = Array.new(5){Array.new(5,0)}
      @report_after_matrix = Array.new(5){Array.new(5,0)}
      Report.within_timerange(@start_date, @end_date).each do |report|
        if report.severity_after.present? && report.likelihood_after_index.present?
          @report_after_matrix[report.severity_after.to_i][report.likelihood_after_index] =
            @report_after_matrix[report.severity_after.to_i][report.likelihood_after_index] + 1
        end
        if report.severity.present? && report.likelihood_index.present?
          @report_matrix[report.severity.to_i][report.likelihood_index] =
            @report_matrix[report.severity.to_i][report.likelihood_index] + 1
        end
      end
      @matrix_title = "Baseline Risk Analysis: Reports"
      @after_title = "Substitute Risk Analysis: Reports"


    # Safety Risk Management Module
    else



      @hazard_matrix = Array.new(5){Array.new(5,0)}
      @hazard_after_matrix = Array.new(5){Array.new(5,0)}
      Hazard.within_timerange(@start_date, @end_date).each do |hazard|
        if hazard.severity_after.present? && hazard.likelihood_after_index.present?
          @hazard_after_matrix[hazard.severity_after.to_i][hazard.likelihood_after_index] =
            @hazard_after_matrix[hazard.severity_after.to_i][hazard.likelihood_after_index] + 1
        end
        if hazard.severity.present? && hazard.likelihood_index.present?
          @hazard_matrix[hazard.severity.to_i][hazard.likelihood_index] =
            @hazard_matrix[hazard.severity.to_i][hazard.likelihood_index] + 1
        end
      end
      @sra_matrix = Array.new(5){Array.new(5,0)}
      @sra_after_matrix = Array.new(5){Array.new(5,0)}
      # Sra.within_timerange(@start_date, @end_date).each do |sra|
      #   if sra.severity_after.present? && sra.likelihood_after_index.present?
      #     @sra_after_matrix[sra.severity_after.to_i][sra.likelihood_after_index]=@sra_after_matrix[sra.severity_after.to_i][sra.likelihood_after_index]+1
      #   end
      #   if sra.severity.present? && sra.likelihood_index.present?
      #     @sra_matrix[sra.severity.to_i][sra.likelihood_index]=@sra_matrix[sra.severity.to_i][sra.likelihood_index]+1
      #   end
      # end
      @matrix_title = "Baseline Risk Analysis: Hazards"
      @after_title = "Substitute Risk Analysis: Hazards"

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
        if x.validator == current_user
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


    elsif session[:mode] == "ASAP"
      if current_user.has_access("meeting", "index")
        meetings = Meeting.where("status != ? and type is null", "Closed")
        meetings = meetings.select{|x| x.has_user(current_user)}
        meetings.each do |a|
          @calendar_entries.push({
            :url => meeting_path(a),
            :start => a.get_time("meeting_start"),
            :end => a.get_time("meeting_end"),
            :title => "Meeting \##{a.id}",
            :color => "khaki",
            :textColor => "darkslategrey",
            :description => a.get_tooltip
          })
        end
      end

      if current_user.has_access("submissions", "index")
        submissions = Submission.preload(:template).where("completed = ? and event_date is not ?", true, nil)
          .can_be_accessed(current_user)
          .by_emp_groups(params[:emp_groups])
        submissions.each do |a|
          @calendar_entries.push({
            :url => submission_path(a),
            :start => a.get_date,
            :title => "#{a.template.name} ##{a.get_id}",
            :textColor => "darkslategrey",
            :description => a.description,
            :color => group_to_color(a.template.emp_group)
          })
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
        if a.scheduled_completion_date.present?
          @calendar_entries.push({
            :url => sra_path(a),
            :start => a.get_completion_date,
            :color => (a.overdue ? "lightcoral" : "skyblue"),
            :textColor => "darkslategrey",
            :title=>"SRA ##{a.id}: "+ a.title + " (#{a.status})"
          })
        end
      end

      risk_controls = RiskControl.where(status: 'Assigned', responsible_user_id: current_user_id)
      risk_controls << RiskControl.where(status: 'Pending Approval', approver_id: current_user_id)
      risk_controls.flatten.each do |a|
        if a.scheduled_completion_date.present?
          @calendar_entries.push({
            :url => risk_control_path(a),
            :start => a.get_completion_date,
            :color => (a.overdue ? "lightcoral" : "skyblue"),
            :textColor => "darkslategrey",
            :title => "Risk Control ##{a.id}: " + a.title + " (#{a.status})"
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



  def prepare_analytics
    start_time = Time.now
    @start_date ||= nil
    @end_date ||= nil
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

    @employee_groups = Template.select("distinct emp_group").map(&:emp_group)

    if session[:mode] == "ASAP"
      if current_user.has_access('submissions','index')
        @submissions = Submission.where(:completed => 1)
          .can_be_accessed(current_user)
          .within_timerange(@start_date, @end_date)
          .by_emp_groups(params[:emp_groups])
          .group_by{|x| x.template.name}
      end
      if current_user.has_access('records','index')
        @records = Record.can_be_accessed(current_user)
          .within_timerange(@start_date, @end_date)
          .by_emp_groups(params[:emp_groups])
          .group_by(&:status)
      end
      if current_user.has_access('reports','index')
        @reports = Report.within_timerange(@start_date, @end_date)
          .group_by(&:status)
      end
      if current_user.has_access('meetings','index')
        @meetings = Meeting.find(:all).sort{|x,y| status_index(x) <=> status_index(y)}.group_by(&:status)
      end
      if current_user.has_access('corrective_actions','index')
        @corrective_actions = CorrectiveAction.within_timerange(@start_date, @end_date).group_by(&:status)
      end

    elsif session[:mode] == "SMS"
      if current_user.has_access("audit","index")
        audits = Audit.regulars.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
        @audits = audits.group_by{|x| x.status}
        if (temp = audits.select{|x| x.overdue}).present?
          @audits["Overdue"] = temp
        end
      end
      if current_user.has_access("findings","index")
        findings = Finding.within_timerange(@start_date, @end_date).sort{|x,y| status_index(x)<=>status_index(y)}
        @findings = findings.group_by{|x| x.status}
        if (temp = findings.select{|x| x.overdue}).present?
          @findings["Overdue"] = temp
        end
      end
      if current_user.has_access("sms_actions","index")
        corrective_actions = SmsAction.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @corrective_actions = corrective_actions.group_by{|x| x.status}
        if (temp = corrective_actions.select{|x| x.overdue}).present?
          @corrective_actions["Overdue"] = temp
        end
      end
      if current_user.has_access("inspections","index")
        inspections = Inspection.regulars.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @inspections = inspections.group_by{|x| x.status}
        if (temp = inspections.select{|x| x.overdue}).present?
           @inspections["Overdue"] = temp
        end
      end
      if current_user.has_access("evaluations","index")
        evaluations=Evaluation.regulars.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @evaluations = evaluations.group_by{|x| x.status}
        if (temp = evaluations.select{|x| x.overdue}).present?
          @evaluations["Overdue"] = temp
        end
      end
      if current_user.has_access("recommendations","index")
        recommendations = Recommendation.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @recommendations = recommendations.group_by{|x| x.status}
        if (temp = recommendations.select{|x| x.overdue}).present?
          @recommendations["Overdue"] = temp
        end
      end
      if current_user.has_access("investigations","index")
        investigations = Investigation.regulars.within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @investigations = investigations.group_by{|x| x.status}
        if (temp = investigations.select{|x| x.overdue}).present?
          @investigations["Overdue"] = temp
        end
      end

    elsif session[:mode] == "SRM"
      sras = Sra.within_timerange(@start_date, @end_date)
        .sort{|x,y| status_index(x) <=> status_index(y)}
      @sras = sras.group_by{|x| x.status}
      if (temp = sras.select{|x| x.overdue}).present?
        @sras["Overdue"]=temp
      end
      hazards = Hazard.within_timerange(@start_date, @end_date)
        .sort{|x,y| status_index(x) <=> status_index(y)}
      @hazards = hazards.group_by{|x| x.status}
      risk_controls = RiskControl.within_timerange(@start_date, @end_date)
        .sort{|x,y| status_index(x) <=> status_index(y)}
      @risk_controls = risk_controls.group_by{|x| x.status}
      if (temp=risk_controls.select{|x| x.overdue}).present?
        @risk_controls['Overdue'] = temp
      end
      Rails.logger.debug "@risk_controls = #{@risk_controls.inspect}"
      safety_plans = SafetyPlan.within_timerange(@start_date, @end_date)
        .sort{|x,y| status_index(x)<=>status_index(y)}
      @safety_plans = safety_plans.group_by{|x| x.status}

    elsif session[:mode] == "SMS IM"
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
    end
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
    prepare_analytics
    prepare_calendar
    if CONFIG::GENERAL[:base_risk_matrix]
      prepare_risk_matrix
    else
      prepare_special_risk_matrix
    end
  end



  def load_options_asap
    @submissions = Submission.where("completed = ? and event_date is not ?", true, nil)
      .can_be_accessed(current_user)
      .by_emp_groups(params[:emp_groups])
    #@submissions = Submission.where(:completed => 1).can_be_accessed(current_user).within_timerange(@start_date, @end_date).by_emp_groups(params[:emp_groups]).group_by{|x| x.template.name}
  end

  def query_all
    load_objects(session[:mode])
    @fields = []
    @types.each do |k, v|
      @fields << Object.const_get(v)
        .get_meta_fields('show')
        .keep_if{|x| x[:field]}
        .map{|f| f[:title]}
        .compact
    end
    @fields = @fields.flatten.uniq.sort
    @logical_types = ['Equals To', 'Not equal to', 'Greater than', 'Less than']
    @operators = ["AND", "OR"]
  end


  def search_all
    @title = params[:report_type]
    @object_type = Object.const_get(params[:report_type])
    @table_name = @object_type.table_name
    @headers = @object_type.get_meta_fields('index')
    @fields = @object_type.get_meta_fields('show').keep_if{|x| x[:field]}
    all_records = @object_type.all.map(&:id)
    results = []
    if params[:base].present?
      results = expand_emit_all(params[:base], results, all_records, 'AND')
    else
      results = all_records
    end
    @records = @object_type.find(results)
  end


  def expand_emit_all(expr, result, all_records, operator)
    expr.each_pair do |index, value|
      if index.to_i > 0
        if !value['operator'].blank?
          operator = value['operator']
        end
        if operator == 'AND'
          temp_result = emit_all(value, all_records, all_records, operator)
        else
          temp_result = emit_all(value, result, all_records, operator)
        end
        if operator == 'AND'
          if result.length == 0
            result = all_records & temp_result
          else
            result = result & temp_result
          end
        else
          result = result | temp_result
        end
      end
    end
    result
  end



  def emit_all(expr, result, all_records, operator)
    base = @object_type.where(:id => all_records)

    # Nested conditions
    if !expr['operator'].blank?
      if expr['operator'] == 'AND'
        expand_emit_all(expr, all_records, all_records, expr['operator'])
      else
        expand_emit_all(expr, result, all_records, expr['operator'])
      end

    else
      if operator == 'AND'
        base = @object_type.where(:id => result)
      elsif operator == 'OR'
        base = @object_type.where(:id => all_records)
      end

      if expr['value'].blank?
        return []
      end

      field = @fields.select{|header| header[:title] == expr['field']}.first

      if field.present?
        if field[:type] == 'user'
          expr_val = expr['value']
          expr_val = User
            .where('full_name LIKE ?', "%" + expr_val + "%")
            .map{|x| x.id.to_s}.join(",")
        else
          expr_val = expr['value']
        end

        begin
          # get result from logic
          if expr['logic'] == "Equals To"
            case field[:type]
            when "boolean_box"
              base.keep_if{|x| (x.send(field[:field]) ? 'Yes' : 'No').downcase == expr_val.downcase}
            when "user"
              base.keep_if{|x|
                (x.send(field[:field]).to_s.present?) &&
                (expr_val.split(",").include? x.send(field[:field]).to_s)}
            else
              base.keep_if{|x|
                (x.send(field[:field]).to_s.present?) &&
                (x.send(field[:field]).to_s.downcase.include? expr_val.downcase)}
            end
          elsif expr['logic'] == "Not equal to"
            if field[:type] == 'boolean_box'
              base.keep_if{|x|
                (x.send(field[:field]) ? 'Yes' : 'No').downcase != expr_val.downcase}
            else
              base.keep_if{|x|
                (x.send(field[:field]).to_s.present?) &&
                !(x.send(field[:field]).to_s.downcase.include? expr_val.downcase)}
            end

          elsif expr['logic'] == "Greater than"
            if field[:type] == "datetime" || field[:type] == "date"
              base.keep_if{|x|
                (x.send(field[:field]).present?) &&
                (x.send(field[:field]).to_time > expr_val.to_time)}
            else
              base.keep_if{|x|
                (x.send(field[:field]).present?) &&
                (x.send(field[:field]).to_f > expr_val.to_f)}
            end

          elsif expr['logic'] == "Less than"
            if field[:type] == "datetime" || field[:type] == "date"
              base.keep_if{|x|
                (x.send(field[:field]).present?) &&
                (x.send(field[:field]).to_time < expr_val.to_time)}
            else
              base.keep_if{|x|
                (x.send(field[:field]).present?) &&
                (x.send(field[:field]).to_f < expr_val.to_f)}
            end
          end
        rescue => e
          redirect_to query_all_home_index_path, flash: {danger: "Invalid Input."}
        end
      end
      base.map(&:id)
    end

  end



  def draw_chart
    @object_type = Object.const_get(params[:object_type])
    @result = @object_type.where(:id => params[:records_id].split(","))
    @label = params[:field_id]

    @field = @object_type.get_meta_fields('show')
      .select{|header| header[:title] == @label}.first

    result_id = []
    @result.each{ |r| result_id << r.id }

    # Create Hash to store value and occurance
    @data = Hash.new

    # Create Hash for each checkbox options
    if @field[:type] == "checkbox"
      temp_hash = Hash.new
      temp_hash = Hash[@field[:options].collect{|item| [item, 0]}]
      @data = @data.merge(temp_hash)

    # Create key value pair for unique values
    else
      @data = Hash[
        @result
          .map{|x| x.send(@field[:field])}
          .compact
          .uniq
          .collect{|item| [item, 0]}
      ]
    end

    # Iterate through result to update Hash
    @result.each do |r|
      value = r.send(@field[:field])
      if @field[:type] == 'checkbox'
        if value.present?
          value.each do |v|
            if @data[v].present?
              @data[v] += 1
            end
          end
        end
      else
        if value.present?
          if @data[value].present?
            @data[value] += 1
          end
        end
      end
    end

    @data = @data.sort_by{|k, v| v}
    @data = @data.reject{|k, v| v < 1}
    if @data.present?
      @data.reverse!
    end


    if @field[:type] == "datetime" || @field[:type] == "date"
      @daily_data = Hash.new(0)
      @monthly_data = Hash.new(0)
      @yearly_data = Hash.new(0)
      @data.each do |x|
        daily = x[0].to_datetime.beginning_of_day
        monthly = x[0].to_datetime.beginning_of_month
        yearly = x[0].to_datetime.beginning_of_year
        @daily_data[daily] += x[1]
        @monthly_data[monthly] += x[1]
        @yearly_data[yearly] += x[1]
      end
      @daily_data = @daily_data.sort_by{|k,v| k}
      @monthly_data = @monthly_data.sort_by{|k,v| k}
      @yearly_data = @yearly_data.sort_by{|k,v| k}
      render :partial => "/home/query/datetime_chart_view"
    elsif @field[:type] == "user"
      @data = @data.map{|k, v| [User.find(k).full_name, v]}
      render :partial => "/home/query/chart_view"
    else
      render :partial => "/home/query/chart_view"
    end

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
    @path = send("#{@table.table_name}_path")
    meta_field_args = ['show']
    meta_field_args.push('admin') if current_user.admin?
    @terms = @table.get_meta_fields(*meta_field_args).keep_if{|x| x[:field].present?}
    render :partial => '/shared/advanced_search'
  end


end
