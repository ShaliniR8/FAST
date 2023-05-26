module ApplicationHelper
  include ShowDataHelper
  include QueriesHelper

  def get_filtered_data(params)
    use_advanced_search = params[:advance_search].present? && params[:advance_search]["advance_search"]
    has_owner = params[:advance_search].present? && params[:advance_search][:type].present?

    object_info = CONFIG.hierarchy[session[:mode]][:objects][params[:object_name]]
    object = Object.const_get(params[:object_name]) #.preload(object_info[:preload])

    # filter by status & handle advanced search + overdue
    if use_advanced_search
      if has_owner
        data, params[:columns] = handle_advance_search(object.where(owner_type: params[:advance_search][:type]).can_be_accessed(current_user), params[:advance_search], params[:columns])
      else
        data, params[:columns] = handle_advance_search(object.can_be_accessed(current_user), params[:advance_search], params[:columns])
      end
    else
      data = params[:status] == 'All' || params[:status] == 'Overdue' ? object.can_be_accessed(current_user) : object.where(status: params[:status]).can_be_accessed(current_user)
      # data = params[:status] == 'All' || params[:status] == 'Overdue' ? object : object.where(status: params[:status])
    end

    if params[:object_name] == 'Submission'
      data = data.where(:completed => 1)
    end

    if params[:status] == 'Overdue'
      data = data.select{|x| x.overdue}
    end


    # filter by individual column search value
    params[:columns].each do |key, value|
      column_search_value = value["search"]["value"].downcase

      if column_search_value.present?
        data = data.select { |record|
          column_name = value["data"]
          column_value = handle_format_data(column_name, record.send(column_name)).to_s.downcase
          (column_value.include? column_search_value).present?
        }
      end
    end

    data
  end

  def get_only_current_module_notices(current_module:, unread: [1, 2])
    current_module_owner_types = CONFIG.hierarchy[current_module][:objects].keys
    current_user.notices.where(status: unread).where(owner_type: current_module_owner_types).sort_by(&:created_at)
  end


  def handle_search_term(term, search_value, columns)
    value = 1

    columns = columns.each { |column|
      column[value][:search][:value] = search_value if column[value][:data] == term
    }
  end


  def handle_search_date(term, start_date, end_date, data)
    data.keep_if { |record|
      # start_date = start_date.to_datetime
      # end_date = end_date.to_datetime
      record.send(term).to_datetime.between?(start_date.beginning_of_day, end_date.end_of_day) rescue false
    }
  end


  def handle_advance_search(data, params, columns)

    # TODO: Refactor
    # risk matrix number from dashboard
    if (["severity", "likelihood"].include? params["searchterm_1"]) || (["severity", "likelihood"].include? params["searchterm_2"])

      field_1 = params["field_1"].to_i
      field_2 = params["field_2"].to_i

      risk_color = CONFIG::MATRIX_INFO[:risk_table][:rows_color][field_1][field_2]

      params["field_1"] = CONFIG::MATRIX_INFO[:risk_definitions][risk_color.to_sym][:rating]
      params["searchterm_1"] = "get_risk_classification"

      params.delete("field_2")
      params.delete("searchterm_2")

    elsif (["severity_after", "likelihood_after"].include? params["searchterm_1"]) || (["severity_after", "likelihood_after"].include? params["searchterm_2"])

      field_1 = params["field_1"].to_i
      field_2 = params["field_2"].to_i

      risk_color = CONFIG::MATRIX_INFO[:risk_table][:rows_color][field_1][field_2]

      params["field_1"] = CONFIG::MATRIX_INFO[:risk_definitions][risk_color.to_sym][:rating]
      params["searchterm_1"] = "get_risk_classification_after"

      params.delete("field_2")
      params.delete("searchterm_2")
    end

    search_fields = [
      {
        term: params[:searchterm_1],
        field: params[:field_1],
        start_date: params[:start_date_1],
        end_date: params[:end_date_1]
      },
      {
        term: params[:searchterm_2],
        field: params[:field_2],
        start_date: params[:start_date_2],
        end_date: params[:end_date_2]
      },
      {
        term: params[:searchterm_3],
        field: params[:field_3],
        start_date: params[:start_date_3],
        end_date: params[:end_date_3]
      },
      {
        term: params[:searchterm_4],
        field: params[:field_4],
        start_date: params[:start_date_4],
        end_date: params[:end_date_4]
      }
    ]

    if params[:advance_search].present?

      object = Object.const_get(data[0].class.name)

      # date range from dashboard
      if params[:start_date].present? && params[:end_date].present?
        start_date = Time.zone.parse(params[:start_date]) if params[:start_date].is_a?(String)
        end_date = Time.zone.parse(params[:end_date])     if params[:end_date].is_a?(String)

        if params[:emp_groups].present?
          data = object.by_emp_groups(params[:emp_groups]).can_be_accessed(current_user).within_timerange(start_date, end_date)
        else
          data = object.can_be_accessed(current_user).within_timerange(start_date, end_date)
        end

        # status from dashboard
        data = data.select { |x| x.status == params[:status] } if params[:status].present?
      elsif params[:emp_groups].present?
        data = object.by_emp_groups(params[:emp_groups]).can_be_accessed(current_user)

        # status from dashboard
        data = data.select { |x| x.status == params[:status] } if params[:status].present?
      end

      search_fields.each do |field|
        if field[:term].present?
          if field[:field].present?
            columns = handle_search_term(field[:term], field[:field], columns)
          elsif field[:start_date].present? && field[:end_date].present?
            start_date = field[:start_date].to_date
            end_date = field[:end_date].to_date
            data = handle_search_date(field[:term], start_date, end_date, data)
          end
        end
      end
    end

    return [data, columns]
  end


  def handle_format_data(column_name, data)
    columns_to_format = %w[viewer_access event_date]
    return data unless columns_to_format.include? column_name

    case column_name
    when 'viewer_access'
      boolean_options = {true => 'Yes', false => 'No'}
      return boolean_options[data]
    when 'event_date'
      return datetime_to_string(data)
    end
  end


  def get_ordered_data(data, order, object_name)
    columns = get_data_table_columns(object_name).map { |col| col[:data] } #.reject { |x| x == 'actions' || x == 'get_additional_info' || x == 'get_occurrences' }
    order_by = columns[order['0']['column'].to_i]

    if order['0']['dir'] == "asc"
      data = data.sort_by { |record| [record.send(order_by) ?  1 : 0, record.send(order_by)] }
    else
      data = data.sort_by { |record| [record.send(order_by) ?  1 : 0, record.send(order_by)] }.reverse
    end
  end


  def get_data_table_columns(object_name)
    fields = Object.const_get(object_name).get_meta_fields('index')
      .map { |field| { data: field[:field], title:field[:title] } } # DataTable Column Format
      .tap { |fields|
          # fields << { data: 'get_additional_info', title: 'Additional Info'} if object_name == 'Record'
          fields << { data: 'actions', title: 'Action'}
      }
  end


  # TODO: replace Record
  def format_index_column_data(records:, object_name:)
    fields =  Object.const_get(object_name).get_meta_fields('index')
    boolean_options = {true => 'Yes', false => 'No'}

    data = []
    records.each do |record|
      record_hash = {}

      fields.each do |field|
        field_name = field[:field]
        field_value = record.send(field_name)
        field_type = field[:type]
        field_display = field[:display]

        field_value = case field_type
          when 'boolean', 'boolean_box'
            boolean_options[field_value]
          when 'date'
            date_to_string(field_value)
          when 'datetime'
            if CONFIG.sr::GENERAL[:submission_time_zone]
              if field_value.present? && field_name == "event_date"
                display_date_time_in_zone(date_time: field_value, time_zone: CONFIG::GENERAL[:time_zone], display_zone: display_local_time_zone)
              end
            else
              datetime_to_string(field_value)
            end
          when 'datetimez'
            datetimez_to_string(field_value)
          when 'user'
            if field_display.present?
              record.send(field_display)
            else
              field_value
            end
          when 'textarea'
            (field_value.length > 50 ? "#{field_value[0..50]}..." : "#{field_value[0..50]}") rescue ''
          when 'list'
            field_value.gsub('<br>',', <br>')
          when 'select'
            if field_display.present?
              field_display[field_value]
            else
              field_value
            end
          else
            field_value
          end

        record_hash[field_name] = field_value
      end


      # TODO: Refactor here

      # actions
      open_link = "<a href="+"/#{object.table_name}/#{record.id} "+"class='btn btn-lightblue mr5 mb5'>Open</a>"
      open_in_new_tab_link = "<a href="+"/#{object.table_name}/#{record.id} "+"class='btn btn-lightblue mr5 mb5' target='_blank'>Open in New Tab</a>"

      # risk matrix color
      risk_color = CONFIG::MATRIX_INFO[:risk_table_index][record_hash['get_risk_classification']]
      if record_hash['get_risk_classification'].present?
        record_hash['get_risk_classification'] =
          "<span class='risk_color #{risk_color}'>#{record_hash['get_risk_classification']}</span>"
      end

      risk_color = CONFIG::MATRIX_INFO[:risk_table_index][record_hash['get_risk_classification_after']]
      if record_hash['get_risk_classification_after'].present?
        record_hash['get_risk_classification_after'] =
          "<span class='risk_color #{risk_color}'>#{record_hash['get_risk_classification_after']}</span>"
      end

      # if object_name == 'Record'
      #   # additional_info
      #   additional_info = record.get_additional_info
      #   additional_info.map! do |field|
      #     "<b>#{field[:label]}</b>: #{field[:value]}<br><br>" if field[:value].present?
      #   end
      #   record_hash['get_additional_info'] = additional_info
      # end

      record_hash['actions'] = open_link + open_in_new_tab_link

      data << record_hash
    end

    data
  end


  def getAlltemplates
    return Template.find(:all)
  end


  def convert_to_utc(date_time:, time_zone:)
    time_zone = 'UTC' if time_zone.blank?
    time_zone = ActiveSupport::TimeZone.new(time_zone)
    time_zone = ActiveSupport::TimeZone.new('UTC') if time_zone.blank?
    date_time = DateTime.parse(date_time) rescue time_zone.at(Time.now)
    time_zone.local_to_utc(date_time)
  end


  def display_date_time_in_zone(date_time:, time_zone:, display_zone: time_zone)
    datetime_to_string(date_time.in_time_zone(time_zone)) + " #{display_zone}"
  end


  def display_local_time_zone
    Time.now.in_time_zone(CONFIG::GENERAL[:time_zone]).strftime('%Z')
  end


  # Calculate the severity based on airport's risk matrix
  def calculate_severity(list)
    return CONFIG.calculate_severity(list)
  end

  # Calculate the probability based on airport's risk matrix
  def calculate_probability(list)
    return CONFIG.calculate_probability(list)
  end

  def print_severity(owner, severity_score)
    return CONFIG.print_severity(owner, severity_score)
  end

  def print_probability(owner, probability_score)
    return CONFIG.print_probability(owner, probability_score)
  end

  def print_risk(probability_score, severity_score)
    return CONFIG.print_risk(probability_score, severity_score)
  end

  def special_matrix
    #@js_link="/javascripts/#{AIRLINE_CODE}/risk_matrix.js"
    @severity_table= CONFIG::MATRIX_INFO[:severity_table]
    @probability_table= CONFIG::MATRIX_INFO[:probability_table]
    @risk_table= CONFIG::MATRIX_INFO[:risk_table]
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

  def load_special_matrix_form(target_name, risk_type, target=nil)
    @target = target
    @target_name = target_name
    case risk_type
    when 'mitigate'
      @severity_field = "mitigated_severity"
      @probability_field = "mitigated_probability"
    when 'baseline'
      @severity_field = "severity_extra"
      @probability_field = "probability_extra"
    end
    special_matrix
  end

  def choose_load_special_matrix_form(target, risk_type)
    if defined?(CONFIG::RISK_ARRAY) #TODO- This will always be the case, clear out excess
      if (CONFIG::RISK_ARRAY[risk_type.pluralize.to_sym][:form].present?)
        form_type = CONFIG::RISK_ARRAY[risk_type.pluralize.to_sym][:form]
        load_special_matrix_form(risk_type, form_type, target)
      end
    else
      load_special_matrix_form(risk_type, 'baseline', target)
    end
  end

  def load_special_matrix(target)
    @target = target
    special_matrix
  end

  def print_special_matrix(target)
    load_special_matrix(target)

    @notes = target.statement

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
      "lightskyblue"
    when "cabin", "inflight", "afghanistan"
      "coral"
    when "dispatch", "ecuador"
      "goldenrod"
    when "maintenance"
      "thistle"
    when "general"
      'mediumaquamarine'
    when "ground"
      'peru'
    when "observation" #observation was added for a NAMS change request
      'crimson'
    when "west-congo"
      'seagreen'
    when "east-congo", "nampa"
      'darkturquoise'
    when "lesotho", "liberia", "haiti"
      'dodgerblue'
    when "guinea", "kalimantan"
      'yellow'
    when "laos", "mozambique", "papua"
      'salmon'
    when "suriname"
      'darkolivegreen'
    else
      "lightgray"
    end

  end




  def g_link(entry)
    case entry.class.name.demodulize
    when 'Message'
      entry_url = message_url(entry)
    when 'Submission'
      entry_url = submission_url(entry)
    when 'Record'
      entry_url = record_url(entry)
    when 'Report'
      entry_url = report_url(entry)
    when 'Meeting'
      entry_url = meeting_url(entry)
    when 'SrmMeeting'
      entry_url = srm_meeting_url(entry)
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
    when 'Recommendation'
      entry_url = recommendation_url(entry)
    when 'Sra'
      entry_url = sra_url(entry)
    when 'Hazard'
      entry_url = hazard_url(entry)
    when 'RiskControl'
      entry_url = risk_control_url(entry)
    when 'SmsAction'
      entry_url = sms_action_url(entry)
    when 'SafetyPlan'
      entry_url = safety_plan_url(entry)
    when 'VpIm', "JobAid", "FrameworkIm"
      entry_url = im_url(entry)
    when 'SmsTask'
      entry_url = eval("#{entry.owner_type.underscore}_url(entry.owner)")
    when 'Newsletter'
      entry_url = newsletter_url(entry)
    when 'SafetySurvey'
      entry_url = safety_survey_url(entry)
    when 'Query'
      entry_url = query_url(entry)
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
    when 'Query'
      entry_url = use_url ? query_url(entry) : query_path(entry)
    end
    "    <a href='#{entry_url}'>#{message}</a>"
  end

  # def link_to_add_fields(name, f, association, locals={}, linkOptions={}, customTarget=nil, partial:nil)
  #   target = customTarget || association.to_s
  #   new_object = Object.const_get(association.to_s.singularize.titleize.delete(' ')).new
  #   #new_object = Object.const_get(target.singularize.titleize.delete(' ')).new
  #   partial ||= "/forms/add_fields/#{association.to_s.singularize.downcase}_fields" # #{association.to_s.singularize.downcase}_fields
  #   fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
  #     render(partial, :f => builder, :source => 'New', :guest => @guest, :locals => locals)
  #   end
  def link_to_add_fields(name, f, association, locals={}, linkOptions={}, customTarget=nil, partial:nil)
    partial ||= "/forms/add_fields/#{association.to_s.singularize.downcase}_fields" # #{association.to_s.singularize.downcase}_fields
    #partial ||= "#{association.to_s.singularize.downcase}_fields"
    target = customTarget || association.to_s
    new_object = Object.const_get(association.to_s.singularize.titleize.delete(' ')).new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render partial, f:builder, source:'New', guest:@guest, locals: locals
    end
    link_to_function name,
      "add_fields(this, '#{association}', '#{escape_javascript(fields)}', '#{target}')",
      **linkOptions
  end




  def link_to_fields(name, form, association, field_class, template, insert_location,options={})
    new_object = Object.const_get(field_class).new
    fields = form.fields_for(association,new_object, :child_index => "new_#{association}") do |builder|
      render(template, :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\",\"#{insert_location}\")", options)
  end



  def link_to_agenda_fields(name, association, field_class, template, insert_location,options={})
    new_object = Object.const_get(field_class).new
    fields = fields_for(association,new_object, :child_index => "new_#{association}") do |builder|
      render template
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\",\"#{insert_location}\")", options)
  end



  def link_to_add_blocks(name, name_space, insert_space)
    if name == "Add Threshold"
      link_to_function(name, "add_threshold_block(this, \"#{name_space}\", \"#{insert_space}\")")
    else
      link_to_function(name, "add_blocks(this, \"#{name_space}\", \"#{insert_space}\")")
    end
  end


  def calculate_column_size(field:)
    xs_val = field.display_size.to_s
    xs_val = '6' if xs_val.to_i < 6

    size = " col-md-" + field.display_size.to_s +
           " col-xs-" + xs_val +
           " col-sm-" + field.display_size.to_s +
           " col-lg-" + field.display_size.to_s
    return size
  end


  def group_by_column_size_and_nested_fields(fields:)
    arr_group_by_column_size = []
    arr_temp = []
    column_size = 0

    fields.each do |field|
      # make new row when column size exceed 12
      if field.display_size + column_size > 12
        column_size = 0
        arr_group_by_column_size << arr_temp
        arr_temp = []
      end

      # add field in the row
      column_size += field.display_size
      arr_temp << field

      # make new row when there is nested_fields
      if field.nested_fields.present?
        column_size = 0
        arr_group_by_column_size << arr_temp
        arr_temp = []
      end
    end

    arr_group_by_column_size << arr_temp
    arr_group_by_column_size.reject{|x| x.empty?}
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

  def load_objects(module_name)
    @types = CONFIG.hierarchy[module_name][:objects].invert
    @types
  end


  def date_to_string(date)
    date.strftime(CONFIG.getTimeFormat[:dateformat]) rescue ''
  end


  def datetime_to_string(datetime)
    datetime.strftime(CONFIG.getTimeFormat[:datetimeformat]) rescue ''
  end


  def datetimez_to_string(datetime)
    datetime.in_time_zone(CONFIG::GENERAL[:time_zone]).strftime(CONFIG.getTimeFormat[:datetimezformat]) rescue ''
  end


  def latest_android_version
    android_version_uri = URI('https://demo.prosafet.com/api/version.json')
    android_version_json = JSON.parse Net::HTTP.get(android_version_uri)
    android_version_json['version']
  end


  def define_session_permissions
    user = User.find(session[:simulated_id] || session[:user_id])
    accesses = Hash.new{ |h, k| h[k] = [] }
    user.privileges.includes(:access_controls).map{ |priv|
      priv.access_controls.each do |acs|
        accesses[acs.action] << acs.entry
      end
    }
    session[:permissions] = accesses.to_json
  end

  def module_display_to_mode module_display
    module_display = 'OSHA / OJI' if module_display == 'OSHA'
    mode, val = CONFIG.hierarchy.find{ |k, hash| hash[:display_name] == module_display}
    mode
  end

  # used in mobile concerns, assumes that each element of the array has an id
  def array_to_id_map(*args)
    array, key = args
    array.reduce({}) { |id_map, element| id_map.merge({ element[key || 'id'] => element }) }
  end


  def class_to_table(obj_class)
    case obj_class.name
    when 'CorrectiveAction'
      'corrective_actions'
    # TODO more classes need to be handled
    else
      obj_class.name.downcase.pluralize
    end
  end

  # IOSA checklist parsing helper
  def parse_iosa(child, result)
    case child.name
    when 'text'
      result = parse_iosa_text(child, result)
    when 'Emphasis'
      result = parse_iosa_emphasis(child, result)
    when 'nbsp'
      # add new space?
    when 'List'
      result = parse_iosa_list(child, result)
    when 'Para'
      result = parse_iosa_para(child, result)
    end

    return result
  end

  def parse_iosa_para(element, result)
    element.children.each do |child|
      case child.name
      when 'text', 'XRef'
        result = parse_iosa_text(child, result) if child.text != '\n'
      when 'List'
        result = parse_iosa_list(child, result)
      end
    end

    return result
  end

  def parse_iosa_text(element, result)
    result += element.text
  end

  def parse_iosa_emphasis(element, result)
    result += "<b>" + element.children[0].text + "</b>"
  end

  def parse_iosa_list(element, result)
    list_type = element.attributes["type"].value

    case list_type
    when 'lower-roman'
      element.children.each do |item|
        result = parse_iosa_list_item_roman(item, result)
      end
    when 'alphabetical'
      element.children.each do |item|
        result = parse_iosa_list_item_alphabet(item, result)
      end
    when 'bullet'
      element.children.each do |item|
        result = parse_iosa_list_item_bullet(item, result)
      end
    end

    return result
  end

  def parse_iosa_list_item_roman(element, result)
    case element.name
    when 'ListItem'
      if element.children.length == 1

        result += "<br>" if $lower_roman[$index_roman] == 'i'

        result += "&nbsp;&nbsp;" + $lower_roman[$index_roman] + '.&nbsp;&nbsp;' + element.text.to_s + '<br>'
        $index_roman += 1
      else
        temp_str = ''

        element.children.each do |child|
          case child.name
          when 'text'
            temp_str = parse_iosa_text(child, temp_str)
          when 'Emphasis'
            temp_str = parse_iosa_emphasis(child, temp_str)
          when 'List'
            temp_str = parse_iosa_list(child, temp_str)
          end
        end

        result += "&nbsp;&nbsp;" + $lower_roman[$index_roman] + '.&nbsp;&nbsp;' + temp_str + '<br>'
        $index_roman += 1
      end
    end

    return result
  end

  def parse_iosa_list_item_alphabet(element, result)
    case element.name
    when 'List'
      # result = parse_iosa_list(element, result)
    when 'ListItem'
      result += "&nbsp;&nbsp;&nbsp;&nbsp;" + $alphabetical[$index_alphabet] + '.&nbsp;&nbsp;' + element.text.to_s + '<br>'
      $index_alphabet += 1
    end

    return result
  end

  def parse_iosa_list_item_bullet(element, result)
    case element.name
    when 'ListItem'
      result += "&nbsp;&nbsp;" + "- " + element.text.to_s + '<br>'
    end

    return result
  end


  def strip_html_tag(text)
    text.gsub(/<\/?[^>]+>/, '') rescue text
  end


  def get_query_results_ids_helper(query_id)
    query = Query.find(query_id)
    return get_query_results_ids(query)
  end


  def generate_visualization_helper(query_id, x_axis, series, records_ids)
    query = Query.find(query_id)
    object_type = Object.const_get(query.target)
    x_axis_field = get_field_helper(query, object_type, x_axis)
    series_field = get_field_helper(query, object_type, series)

    if series.present? && x_axis.present?
      data = get_data_table_for_google_visualization_with_series(x_axis_field_name: x_axis,
                                                                 x_axis_field_arr: x_axis_field,
                                                                 series_field_arr: series_field,
                                                                 records_ids: records_ids,
                                                                 get_ids: false,
                                                                 query: query)

    elsif x_axis.present?
      data = get_data_table_for_google_visualization_sql(x_axis_field_arr: x_axis_field, records_ids: records_ids, query: query)
      data << ['N/A', 0] if data.length == 1
    elsif series.present?
      data = get_data_table_for_google_visualization_sql(x_axis_field_arr: series_field, records_ids: records_ids, query: query)
      data << ['N/A', 0] if data.length == 1
    else
      data = []
    end

    return data.map{ |x| [x[0].to_s, x[1..-1]].flatten}
  end


  def visualization_title_helper(x_axis, series)
    title = ""

    if series.present? && x_axis.present?
      title = "#{x_axis} By #{series}"
    elsif x_axis.present?
      title = "#{x_axis}"
    elsif series.present?
      title = "#{series}"
    end

    title
  end


  def get_field_helper(query, object_type, field_label)
    # label = field_label.split(',').map(&:strip)[0]
    label = field_label

    # if top level field
    field = object_type.get_meta_fields('show', 'index', 'invisible', 'query', 'close')
      .keep_if{|f| f[:title] == label}.first
    # else check template fields
    field = Template.preload(:categories, :fields)
      .where(id: query.templates)
      .map(&:fields)
      .flatten
      .select{|x| x.label.strip == label.strip}
      .first if field.nil?
    # [field, field_label.split(',').map(&:strip)[1]]
    [field, field_label]
  end

  def article_adjustment(str)
    %w(a e i o u).include?(str[0].downcase) ? "an #{str}" : "a #{str}"
  end

  def show_complete_button(newsletter_id, current_user_id)
    attachments = NewsletterAttachment.where(owner_id: newsletter_id)
    flag = 1
    attachments.each do |a|
      if a.user_ids == nil || (!a.user_ids.include? current_user_id)
        flag = 0
        break
      end
    end
    flag
  end

end
