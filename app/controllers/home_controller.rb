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
      @orm_templates = CONFIG.sr::GENERAL[:enable_orm] ? OrmTemplate.order(:name).all : nil

      # ############################ SUBMISSIONS ########################
      submission_queries = []
      submission_queries << "(completed = true)"
      # template query
      if params[:emp_groups].present?
        templates = Template.where(name: (@permissions['viewer_template_id'] || []).compact, emp_group: params[:emp_groups])
      else
        templates = Template.where(name: (@permissions['viewer_template_id'] || []).compact)
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

      if params[:data_access] == 'related_data'
        @submissions = Submission.preload(:created_by, :template).where(user_id: current_user.id, completed: true)
      else
        @submissions = Submission.preload(:created_by, :template).where(submission_queries.join(' AND '))
      end

      @submissions = @submissions.joins(:template).order('templates.name')

      @submissions = [] if CONFIG::GENERAL[:hide_submission_in_dashboard]

      @grouped_submissions = @submissions.group_by{|x| x.template.name}


      # ############################ RECORDS ########################
      record_queries = []

      # template query
      if params[:emp_groups].present?
        full_template = Template.where(name: (current_user.get_all_templates_hash[:viewer_template_id] || []).compact, emp_group: params[:emp_groups])
        viewer_template = Template.where(name: (current_user.get_all_templates_hash[:viewer_template_deid] || []).compact, emp_group: params[:emp_groups])
      else
        full_template = Template.where(name: (current_user.get_all_templates_hash[:viewer_template_id] || []).compact)
        viewer_template = Template.where(name: (current_user.get_all_templates_hash[:viewer_template_deid] || []).compact)
      end

      # template_query = ["(users_id = #{current_user.id})"]
      template_query = []

      if full_template.length > 0
        template_query << "(templates_id in (#{full_template.map(&:id).join(',')}) OR `records`.users_id = #{current_user.id})"
      end
      if viewer_template.length > 0
        template_query << "(templates_id in (#{viewer_template.map(&:id).join(',')}) AND viewer_access = true)"
      end
      record_queries << "(#{template_query.join(' AND ')})"
      record_queries.delete("()")


      # time range
      if @start_date.present? && @end_date.present?
        record_queries << "event_date >= '#{@start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
        record_queries << "event_date <= '#{@end_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
      end

      if params[:data_access] == 'related_data'
        @records = Record.preload(:created_by, :template).where(users_id: current_user.id)
      else
        @records = Record.preload(:created_by, :template).where(record_queries.join(' AND '))
      end

      @grouped_records = @records.order(:status).group_by(&:status)
      @records_scheduled_completion_date = get_avg_completion_date(@records, 'created_at', 'close_date')

      if CONFIG::GENERAL[:has_gmap]

        @lat = CONFIG::GENERAL[:lat]
        @lng = CONFIG::GENERAL[:lng]
        @zoom = CONFIG::GENERAL[:gMapZoom]

        @coords = Point.joins(record_field: { record: :template }).where(records: { id: @records }).map do |point|
          {
            lat: point.lat.to_f,
            lng: point.lng.to_f,
            id: point.owner.records_id,
            template: point.owner.record.template.name,
            title: point.owner.record.title,
            event_date: point.owner.record.event_date.to_date,
          }
        end
      end

      # ############################ REPORTS ########################
      @reports = Report.joins(:records).where(records: { id: @records }).select("DISTINCT(reports.id), reports.*")
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
        @audits = sort_by_status(Audit.regulars.within_timerange(@start_date, @end_date))
        @grouped_audits = @audits.group_by{|x| x.status}
        if (temp = @audits.select{|x| x.overdue}).present?
          @grouped_audits["Overdue"] = temp
        end
      end
      if current_user.has_access("findings","index")
        @findings = sort_by_status(Finding.within_timerange(@start_date, @end_date))
        @grouped_findings = @findings.group_by{|x| x.status}
        if (temp = @findings.select{|x| x.overdue}).present?
          @grouped_findings["Overdue"] = temp
        end
      end
      if current_user.has_access("sms_actions","index")
        @corrective_actions = sort_by_status(SmsAction.within_timerange(@start_date, @end_date))
        @grouped_corrective_actions = @corrective_actions.group_by{|x| x.status}
        if (temp = @corrective_actions.select{|x| x.overdue}).present?
          @grouped_corrective_actions["Overdue"] = temp
        end
      end
      if current_user.has_access("inspections","index")
        @inspections = sort_by_status(Inspection.regulars.within_timerange(@start_date, @end_date))
        @grouped_inspections = @inspections.group_by{|x| x.status}
        if (temp = @inspections.select{|x| x.overdue}).present?
           @grouped_inspections["Overdue"] = temp
        end
      end
      if current_user.has_access("evaluations","index")
        @evaluations = sort_by_status(Evaluation.regulars.within_timerange(@start_date, @end_date))
        @grouped_evaluations = @evaluations.group_by{|x| x.status}
        if (temp = @evaluations.select{|x| x.overdue}).present?
          @grouped_evaluations["Overdue"] = temp
        end
      end
      if current_user.has_access("recommendations","index")
        @recommendations = sort_by_status(Recommendation.within_timerange(@start_date, @end_date))
        @grouped_recommendations = @recommendations.group_by{|x| x.status}
        if (temp = @recommendations.select{|x| x.overdue}).present?
          @grouped_recommendations["Overdue"] = temp
        end
      end
      if current_user.has_access("investigations","index")
        @investigations = sort_by_status(Investigation.regulars.within_timerange(@start_date, @end_date))
        @grouped_investigations = @investigations.group_by{|x| x.status}
        if (temp = @investigations.select{|x| x.overdue}).present?
          @grouped_investigations["Overdue"] = temp
        end
      end

    when 'SRM'
      @title = "SRA (SRM) Dashboard"
      @sras = sort_by_status(Sra.within_timerange(@start_date, @end_date).by_departments(params[:departments]))
      @grouped_sras = @sras.group_by{|x| x.status}
      if (temp = @sras.select{|x| x.overdue}).present?
        @grouped_sras["Overdue"] = temp
      end

      @hazards = sort_by_status(Hazard.within_timerange(@start_date, @end_date).by_departments(params[:departments]))
      @grouped_hazards = @hazards.group_by{|x| x.status}
      if (temp = @hazards.select{|x| x.overdue}).present?
        @grouped_hazards['Overdue'] = temp
      end

      @risk_controls = sort_by_status(RiskControl.within_timerange(@start_date, @end_date).by_departments(params[:departments]))
      @grouped_risk_controls = @risk_controls.group_by{|x| x.status}
      if (temp = @risk_controls.select{|x| x.overdue}).present?
        @grouped_risk_controls['Overdue'] = temp
      end

      @safety_plans = sort_by_status(SafetyPlan.within_timerange(@start_date, @end_date))
      @grouped_safety_plans = @safety_plans.group_by{|x| x.status}

    when 'SP'
      @title = "Safety Promotion Dashboard"

      if current_user.has_access(Object.const_get('Newsletter').rule_name, "index", admin: CONFIG::GENERAL[:global_admin_default])
        @newsletters = Object.const_get('Newsletter').within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_newsletters = @newsletters.group_by{|x| x.status}
      end

      if current_user.has_access(Object.const_get('SafetySurvey').rule_name, "index", admin: CONFIG::GENERAL[:global_admin_default])
        @safety_surveys = Object.const_get('SafetySurvey').within_timerange(@start_date, @end_date)
          .sort{|x,y| status_index(x) <=> status_index(y)}
        @grouped_safety_surveys = @safety_surveys.group_by{|x| x.status}
      end
    end
  end


  def prepare_calendar
    @calendar_entries = []
    current_user_id = session[:simulated_id] || session[:user_id]


    if session[:mode] == "SMS"

      objects = ['Audit', 'Inspection', 'Evaluation', 'Investigation', 'Finding', 'SmsAction', 'Recommendation']
      objects.each do |x|
        records = Object.const_get(x).where(status: 'Assigned', responsible_user_id: current_user_id).where('due_date IS NOT NULL')
        records << Object.const_get(x).where(status: 'Pending Approval', approver_id: current_user_id).where('due_date IS NOT NULL')
        records.flatten.each do |record|
          x = x == 'SmsAction' ? 'CorrectiveAction' : x
          @calendar_entries.push({
            :url => "#{records.table_name}/#{record.id}",
            :start => record.get_completion_date,
            :color => (record.overdue ? "lightcoral" : "skyblue"),
            :textColor => "darkslategrey",
            :title => "#{x.titleize} ##{record.id}: #{record.title} (#{record.status})"
          })
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

      task_sms_owners = ["Audit", "Inspection", "Evaluation", "Investigation"]
      tasks = SmsTask.where({status: 'Assigned', res: current_user.id, owner_type: task_sms_owners})
      tasks << SmsTask.where({status: 'Pending Approval', app_id: current_user.id, owner_type: task_sms_owners})
      tasks.flatten.each do |x|
        @calendar_entries.push({
          :url => "#{x.owner.class.table_name}/#{x.owner_id}",
          :start => x.due_date,
          :color => (x.overdue ? "lightcoral" : "skyblue"),
          :textColor => "darkslategrey",
          :title => "Task ##{x.id} - #{x.title} (#{x.status})"
        })
      end


    elsif session[:mode] == "ASAP"
      if current_user.has_access("meeting", "index")
        meetings = Meeting.preload(:host, :invitations).where("status != ? and type is null", "Closed")
        meetings = meetings.select{|x| x.has_user(current_user)}
        meetings = meetings.select{|x| x.include_user(current_user)} if params[:data_access] == 'related_data'
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

      if current_user.has_access("submissions", "index") && !@submissions.empty?
        @submissions.joins(:template).each do |a|
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
        @records.select {|x| x.template}.each do |a|
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

      sras = Sra.where(status: 'Assigned', responsible_user_id: current_user_id).where('due_date IS NOT NULL')
      sras << Sra.where(status: 'Pending Review', reviewer_id: current_user_id).where('due_date IS NOT NULL')
      sras << Sra.where(status: 'Pending Approval', approver_id: current_user_id).where('due_date IS NOT NULL')
      sras.flatten.each do |a|
        @calendar_entries.push({
          :url => sra_path(a),
          :start => a.get_due_date,
          :color => (a.overdue ? "lightcoral" : "skyblue"),
          :textColor => "darkslategrey",
          :title=>"SRA ##{a.id}: "+ a.title + " (#{a.status})"
        })
      end

      risk_controls = RiskControl.where(status: 'Assigned', responsible_user_id: current_user_id).where('due_date IS NOT NULL')
      risk_controls << RiskControl.where(status: 'Pending Approval', approver_id: current_user_id).where('due_date IS NOT NULL')
      risk_controls.flatten.each do |a|
        @calendar_entries.push({
          :url => risk_control_path(a),
          :start => a.get_due_date,
          :color => (a.overdue ? "lightcoral" : "skyblue"),
          :textColor => "darkslategrey",
          :title => "Risk Control ##{a.id}: " + a.title + " (#{a.status})"
        })
      end

      hazards = Hazard.where(status: 'Assigned', responsible_user_id: current_user_id).where('due_date IS NOT NULL')
      hazards << Hazard.where(status: 'Pending Approval', approver_id: current_user_id).where('due_date IS NOT NULL')
      hazards.flatten.each do |a|
        @calendar_entries.push({
          :url => hazard_path(a),
          :start => a.get_due_date,
          :color => (a.overdue ? "lightcoral" : "skyblue"),
          :textColor => "darkslategrey",
          :title => "Hazard ##{a.id}: " + a.title + " (#{a.status})"
        })
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

      task_srm_owners = ["Sra", "SafetyPlan"]
      tasks = SmsTask.where({status: 'Assigned', res: current_user.id, owner_type: task_srm_owners})
      tasks << SmsTask.where({status: 'Pending Approval', app_id: current_user.id, owner_type: task_srm_owners})
      tasks.flatten.each do |x|
        @calendar_entries.push({
          :url => "#{x.owner.class.table_name}/#{x.owner_id}",
          :start => x.due_date,
          :color => (x.overdue ? "lightcoral" : "skyblue"),
          :textColor => "darkslategrey",
          :title => "Task ##{x.id} - #{x.title} (#{x.status})"
        })
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

    elsif session[:mode] == "SP"
      if current_user.has_access("newsletters","index")
        newsletters = Newsletter.where("status=?", "Published")
        newsletters = newsletters.select{|x| x.has_user(current_user)}
        newsletters.each do |a|
          @calendar_entries.push({
            :url => newsletter_path(a),
            :start => a.complete_by_date,
            :title => "Newsletter \##{a.id}",
            :color => "khaki",
            :textColor => "darkslategrey",
            :description => a.get_tooltip
          })
        end
      end
      if current_user.has_access("safety_surveys","index")
        safety_surveys = SafetySurvey.where("status=?", "Published")
        safety_surveys = safety_surveys.select{|x| x.has_user(current_user)}
        safety_surveys.each do |a|
          @calendar_entries.push({
            :url => safety_survey_path(a),
            :start => a.complete_by_date,
            :title => "Safety Survey \##{a.id}",
            :color => "skyblue",
            :textColor => "darkslategrey",
            :description => a.get_tooltip
          })
        end
      end
    end
  end


  def prepare_templates
    templates = current_user.get_all_submitter_templates
    @templates = Template.where(:name => templates)
    @templates.keep_if{|x|
      (current_user.has_template_access(x.name).include? "viewer_template_id") ||
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
    when 4,5
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
    @path = params[:path].present? ? params[:path] : eval("#{@table.table_name}_path")
    meta_field_args = ['index']
    discard_terms_list = ["viewer_access", "included_reports", "get_additional_info_html", "get_source"]
    @terms = @table.get_meta_fields(*meta_field_args).keep_if{|x| x[:field].present? && discard_terms_list.exclude?(x[:field])}
    @status = params[:status]
    render :partial => '/shared/advanced_search'
  end


  private

  def sort_by_status(records)
    return [] if records.empty?
    
    modules = {
      'ASAP'   => 'sr',
      'SMS IM' => 'im',
      'SMS'    => 'sa',
      'SRM'    => 'srm',
      'SP'     => 'sp',
    }

    statuses = eval "CONFIG.#{modules[session[:mode]]}::HIERARCHY[:objects]['#{records.first.class.name}'][:status]"
    status_cases = statuses.map.with_index do |status, i|
      "WHEN status = '#{status}' THEN #{i}"
    end
    records.order("CASE #{status_cases.join(' ')} END")
  end


  def get_avg_completion_date(records, start_date = 'created_at', end_date = 'updated_at')
    all_records = records
      .where("`#{records.table.name}`.status NOT IN (?)", ['Closed', 'Completed'])
      .average("DATE(IFNULL(`#{records.table.name}`.#{end_date}, `#{records.table.name}`.updated_at)) - DATE(`#{records.table.name}`.#{start_date})")
    
    return 0 if all_records.nil?
    all_records.round(1)
  end
end
