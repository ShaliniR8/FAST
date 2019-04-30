module ApplicationHelper
  def getAlltemplates
    return Template.find(:all)
  end

  def airport_config
    Object.const_get("#{BaseConfig.airline[:code]}_Config")
  end

  def matrix_config
    airport_config::MATRIX_INFO
  end

  # Calculate the severity based on airport's risk matrix
  def calculate_severity(list)
    return airport_config.calculate_severity(list)
  end

  # Calculate the probability based on airport's risk matrix
  def calculate_probability(list)
    return airport_config.calculate_probability(list)
  end

  def print_severity(owner, severity_score)
    return airport_config.print_severity(owner, severity_score)
  end

  def print_probability(owner, probability_score)
    return airport_config.print_probability(owner, probability_score)
  end

  def print_risk(probability_score, severity_score)
    return airport_config.print_risk(probability_score, severity_score)
  end

  def special_matrix
    #@js_link="/javascripts/#{BaseConfig.airline[:code]}/risk_matrix.js"
    @severity_table= matrix_config[:severity_table]
    @probability_table= matrix_config[:probability_table]
    @risk_table= matrix_config[:risk_table]
  end

  def risk_matrix_initializer
    @color_matrix=Array.new(5){Array.new(5)}
    @color_matrix[0][0] = "yellow"
    @color_matrix[1][0] = "yellow"
    @color_matrix[2][0] = "#60FF60"
    @color_matrix[3][0] = "#60FF60"
    @color_matrix[4][0] = "#60FF60"
    @color_matrix[0][1] = "yellow"
    @color_matrix[1][1] = "yellow"
    @color_matrix[2][1] = "#60FF60"
    @color_matrix[3][1] = "#60FF60"
    @color_matrix[4][1] = "#60FF60"
    @color_matrix[0][2] = "orange"
    @color_matrix[1][2] = "yellow"
    @color_matrix[2][2] = "yellow"
    @color_matrix[3][2] = "#60FF60"
    @color_matrix[4][2] = "#60FF60"
    @color_matrix[0][3] = "orange"
    @color_matrix[1][3] = "orange"
    @color_matrix[2][3] = "yellow"
    @color_matrix[3][3] = "#60FF60"
    @color_matrix[4][3] = "#60FF60"
    @color_matrix[0][4] = "orange"
    @color_matrix[1][4] = "orange"
    @color_matrix[2][4] = "orange"
    @color_matrix[3][4] = "#60FF60"
    @color_matrix[4][4] = "#60FF60"
  end

  def mitigate_special_matrix(target_name, severity_field, probability_field)
    @target_name = target_name
    @severity_field = severity_field
    @probability_field = probability_field
    special_matrix
  end


  def form_special_matrix(target, target_name, severity_field, probability_field)
    @target = target
    @target_name = target_name
    @severity_field = severity_field
    @probability_field = probability_field
    special_matrix
  end

  def load_special_matrix(target)
    @target = target
    special_matrix
  end

  def print_special_matrix(target)
    load_special_matrix(target)

    @severity_score = calculate_severity(target.severity_extra)
    @sub_severity_score = calculate_severity(target.mitigated_severity)

    @probability_score = calculate_probability(target.probability_extra)
    @sub_probability_score = calculate_probability(target.mitigated_probability)

    @print_severity = print_severity(target, @severity_score)
    @print_probability = print_probability(target, @probability_score)
    @print_risk = print_risk(@probability_score, @severity_score)

    @print_sub_severity = print_severity(target, @sub_severity_score)
    @print_sub_probability = print_probability(target, @sub_probability_score)
    @print_sub_risk = print_risk(@sub_probability_score, @sub_severity_score)
  end

  def number_to_percentage(value, total)
    if value.nil? || total.nil?
      "NaN"
    elsif value == 0
      "0%"
    elsif total == 0
      "Infinity"
    else
      "#{(value * 100.0 / total).round(2)}%"
    end
  end

  def datalist(f,field,select_options,options = {})
    result=f.text_field field,options.merge(:list=>"#{field}_list")
    result+=("<datalist id='#{field}_list'>" + select_options+"</datalist>").html_safe
    result.html_safe
  end

  def datalist_tag (field,select_options,options = {})
    result=text_field_tag field,nil,options.merge(:list=>"#{field}_list")
    result+=("<datalist id='#{field}_list'>" + select_options+"</datalist>").html_safe
    result.html_safe
  end

  def status_index(entry)
    case entry.status
    when "New"
      1
    when "Pending Release"
      2
    when "Open"
      3
    when "Meeting Ready"
      3
    when "Under Review"
      4
    when "Linked"
      4
    when 'Pending Review'
      4
    when 'Awaiting Review'
      4
    when "Assigned"
      4
    when "Pending Approval"
      5
    when "Rejected"
      5
    when "Completed"
      6
    when "Closed"
      6
    when "Transit to VP/Part 5"
      6
    else
      6
    end
  end

  def group_to_color(group_name)
    case group_name
    when "flight-crew"
      "LIGHTSKYBLUE"
    when "cabin"
      "CORAL"
    when "dispatch"
      "GOLDENROD"
    when "maintenance"
      "lightsalmon"
    when "general"
      "MEDIUMAQUAMARINE"
    when "ground"
      "DARKTURQUOISE"
    else
      "lightgray"
    end

  end




  def g_link(entry)
    case entry.class.name.demodulize
    when 'Submission'
      entry_url = submission_url(entry)
    when 'Record'
      entry_url = record_url(entry)
    when 'Report'
      entry_url = report_url(entry)
    when 'Meeting'
      entry_url = meeting_url(entry)
    when 'CorrectiveAction'
      entry_url = corrective_action_url(entry)
    when 'Audit'
      entry_url = audit_url(entry)
    when 'Evaluation'
      entry_url = evaluation_url(entry)
    when 'Inspection'
      entry_url = inspection_url(entry)
    when 'Investigation'
      entry_url = investigation_url(entry)
    when 'Finding'
      entry_url = finding_url(entry)
    when 'AuditFinding'
      entry_url = finding_url(entry)
    when 'InspectionFinding'
      entry_url = finding_url(entry)
    when 'EvaluationFinding'
      entry_url = finding_url(entry)
    when 'InvestigationFinding'
      entry_url = finding_url(entry)
    when 'Recommendation'
      entry_url = recommendation_url(entry)
    when 'InvestigationRecommendation'
      entry_url = recommendation_url(entry)
    when 'FindingRecommendation'
      entry_url = recommendation_url(entry)
    when 'Sra'
      entry_url = sra_url(entry)
    when 'Hazard'
      entry_url = hazard_url(entry)
    when 'RiskControl'
      entry_url = risk_control_url(entry)
    when 'SmsAction'
      entry_url = sms_action_url(entry)
    when 'FindingAction'
      entry_url = sms_action_url(entry)
    when 'InvestigationAction'
      entry_url = sms_action_url(entry)
    when 'SafetyPlan'
      entry_url = safety_plan_url(entry)
    else
      entry_url = "N/A"
    end
    "    <a style='font-weight:bold;text-decoration:underline' href='#{entry_url}'>View</a>"
  end




  def generate_link_to(message, entry, use_url=false)
    class_name = entry.class.name.demodulize
    if class_name == "Fixnum"
    end

    case class_name
    # when "CorrectiveAction"
    #   entry_url=use_url ? corrective_action_url(entry) : corrective_action_path(entry)
    when "Submission"
      entry_url = use_url ? submission_url(entry) : submission_path(entry)
    when "Report"
      entry_url = use_url ? report_url(entry) : report_path(entry)
    when "Record"
      entry_url = use_url ? record_url(entry) : record_path(entry)
    when "Meeting"
      entry_url = use_url ? meeting_url(entry) : meeting_path(entry)
    when "VpMeeting"
      entry_url = use_url ? sms_meeting_url(entry) : sms_meeting_path(entry)
    when "JobMeeting"
      entry_url = use_url ? sms_meeting_url(entry) : sms_meeting_path(entry)
    when "SrmMeeting"
      entry_url = use_url ? srm_meeting_url(entry) : srm_meeting_path(entry)
    when "Audit"
      entry_url = use_url ? audit_url(entry) : audit_path(entry)
    when "Finding"
      entry_url = use_url ? finding_url(entry) : finding_path(entry)
    when "AuditFinding"
      entry_url = use_url ? finding_url(entry) : finding_path(entry)
    when "InspectionFinding"
      entry_url = use_url ? finding_url(entry) : finding_path(entry)
    when "InvestigationFinding"
      entry_url = use_url ? finding_url(entry) : finding_path(entry)
    when "EvaluationFinding"
      entry_url = use_url ? finding_url(entry) : finding_path(entry)
    when "SmsAction"
      entry_url = use_url ? sms_action_url(entry) : sms_action_path(entry)
    when "FindingAction"
      entry_url = use_url ? sms_action_url(entry) : sms_action_path(entry)
    when "InvestigationAction"
      entry_url = use_url ? sms_action_url(entry) : sms_action_path(entry)
    when "Inspection"
      entry_url = use_url ? inspection_url(entry) : inspection_path(entry)
    when "Evaluation"
      entry_url = use_url ? evaluation_url(entry) : evaluation_path(entry)
    when "Investigation"
      entry_url = use_url ? investigation_url(entry) : investigation_path(entry)
    when  "Sra"
      entry_url = use_url ? sra_url(entry) : sra_path(entry)
    when "FrameworkIm"
      entry_url = use_url ? im_url(entry) : im_path(entry)
    when "VpIm"
      entry_url = use_url ? im_url(entry) : im_path(entry)
    when "JobAid"
      entry_url = use_url ? im_url(entry) : im_path(entry)
    when "RiskControl"
      entry_url = use_url ? risk_control_url(entry) : risk_control_path(entry)
    when "CorrectiveAction"
      entry_url = use_url ? corrective_action_url(entry) : corrective_action_path(entry)
    when "FindingRecommendation"
      entry_url = use_url ? recommendation_url(entry) : recommendation_path(entry)
    when "InvestigationRecommendation"
      entry_url = use_url ? recommendation_url(entry) : recommendation_path(entry)
    end
    "    <a href='#{entry_url}'>#{message}</a>"
  end

  def link_to_add_fields(name, f, association, locals={})
    target = association.to_s
    new_object = Object.const_get(target.singularize.titleize.delete(' ')).new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize.downcase + "_fields", :f => builder, :source => "New", :guest => @guest, :locals => locals)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{target}\")")
  end




  def link_to_fields(name, form, association, field_class, template, insert_location,options={})
    new_object = Object.const_get(field_class).new
    fields = form.fields_for(association,new_object, :child_index => "new_#{association}") do |builder|
      render(template, :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\",\"#{insert_location}\")", options)
  end




  def link_to_add_blocks(name, name_space, insert_space)
    link_to_function(name, "add_blocks(this, \"#{name_space}\", \"#{insert_space}\")")
  end




  def image_spitter(value)
    Rails.logger.debug("Top Level Application Helper")
    if value == "true"
      #return '<img src="http://www.clker.com/cliparts/a/6/e/8/119498563188281957tasto_8_architetto_franc_01.svg.med.png" width="20" height="20"/>'
      return '<p style="font-size:1.2em; color: red; margin:2px 0 0 0;"> N</p>'
    elsif value =="maint"
      return '<p style="font-size:1.2em; color: orange; margin:2px 0 0 0;"> M</p>'
    else
      #return '<img src="http://innervationenergy.com/images/ies_check.png" width="20" height="20"/>'
      return '<p style="font-size:1.2em; color: green; margin:2px 0 0 0"> Y</p>'
    end
    return ''
  end




  def date_to_string(date)
    date.strftime(BaseConfig.getTimeFormat[:dateformat]) rescue ''
  end



  def datetime_to_string(datetime)
    datetime.strftime(BaseConfig.getTimeFormat[:datetimeformat]) rescue ''
  end

  def latest_android_version
    android_version_uri = URI('https://demo.prosafet.com/api/version.json')
    android_version_json = JSON.parse Net::HTTP.get(android_version_uri)
    android_version_json['version']
  end
end
