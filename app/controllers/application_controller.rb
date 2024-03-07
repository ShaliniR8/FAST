# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include ControllerAuthentication
  include ApplicationHelper

  before_filter :access_validation
  before_filter :send_session
  before_filter :adjust_session
  before_filter :track_activity
  before_filter :set_page_title
  #before_filter :set_last_seen_at
  skip_before_filter :authenticate_user! #Kaushik Mahorker OAuth

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def index
    @object_name = controller_name.classify
    @table_name = controller_name

    @object = CONFIG.hierarchy[session[:mode]][:objects][@object_name]
    @default_tab = params[:status]

    # Datatable Column Info
    @columns = get_data_table_columns(@object_name)
    @columns.delete_if {|x| x[:data] == 'get_additional_info_html'}
    if @object_name == 'Record'
      if !CONFIG.sr::GENERAL[:show_submitter_name].present?
        if !current_user.global_admin?
          @columns.delete_if {|x| x[:data] == 'get_submitter_name'}
        end
      else
        if !current_user.admin?
          @columns.delete_if {|x| x[:data] == 'get_submitter_name'}
        end
      end
    end

    if @object_name == 'Sra' && !CONFIG.srm::GENERAL[:risk_assess_sras].present?
      @columns.delete_if {|x| ["get_risk_classification", "get_risk_classification_after"].include?(x[:data])}
    end

    @column_titles = @columns.map { |col| col[:title] }
    @date_type_column_indices = @column_titles.map.with_index { |val, inx|
      (val.downcase.include?('date') || val.downcase.include?('time')) ? inx : nil
    }.select(&:present?)

    @source_column_indices = @column_titles.map.with_index { |val, inx|
      (val.downcase.include?('source of input')) ? inx : nil
    }.select(&:present?)

    @advance_search_params = params
    @hide_advance_search = ['OSHA'].include? session[:mode]

    render 'forms/index'
  end


  def track_activity
    #if Trial or Demo and user is not prosafet_admin then track log
    track_airline_log = CONFIG::GENERAL[:track_log]
    if track_airline_log
      date_time = DateTime.now.in_time_zone('Pacific Time (US & Canada)')
      file_date = date_time.strftime("%Y%m%d")
      action_time = date_time.strftime("%H:%M")
      file_name = "#{Rails.root}/log/tracker_" << file_date << ".log"
      if current_user.present? && current_user.username != "prosafet_admin" && current_user.username != 'bli'
        tracking_log = Logger.new(file_name)
        if controller_name == "sessions" && action_name == "create"
          ActivityTracker.create(:user_id => current_user.id, :last_active => DateTime.now)
          tracking_log.info("***********LOGIN: #{action_time} #{current_user.full_name} #{controller_name}##{action_name}***********")
        elsif controller_name == "sessions" && action_name == "destroy"
          tracking_log.info("***********LOGOUT #{action_time} #{current_user.full_name} #{controller_name}##{action_name}***********")
        else
          last_tracker = ActivityTracker.where('created_at BETWEEN ? AND ? AND user_id = ?', DateTime.now.beginning_of_day, DateTime.now.end_of_day, current_user.id).last
          last_tracker.update_attributes(:last_active => DateTime.now) if last_tracker.present?
          tracking_log.info("#{action_time} #{current_user.full_name} #{controller_name}##{action_name}")
        end
      end
    end
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def access_validation(strict=false)

    expire_after = 180 # minutes

    if session[:digest].present?
      if request.url == session[:digest].link && session[:digest].expire_date > Time.now.to_date
        return
      end
    end

    Rails.logger.debug("Action #{action_name}, Controller #{controller_name}")
    if session[:last_active].present? && current_user.present?
      Rails.logger.info("User ##{current_user.id}: #{current_user.full_name}")
      define_session_permissions if (current_user.privileges_last_updated > session[:last_active] rescue false)
    end

    # expire oauth token
    if current_token.present?
      oauth_expiration = current_client_application.name == 'prosafet_app_personal' ? 1.week : 3.hours
      oauth_expire_date = Time.now - oauth_expiration
      if current_token.authorized_at < oauth_expire_date
        redirect_to logout_path
        return false
      end
    end

    if !session[:last_active].present?
      session[:last_active] = Time.now
    elsif (Time.now - session[:last_active])/60 > expire_after && !CONFIG::GENERAL[:enable_sso] && !current_token.present?
       redirect_to logout_path
       return false
    else
      session[:last_active] = Time.now
    end

    if current_user.blank?
    else
      if current_user.disable
        redirect_to logout_path
        return false
      elsif !current_user.has_access(controller_name,action_name,admin:CONFIG::GENERAL[:global_admin_default], permissions: (session[:permissions].present? ? JSON.parse(session[:permissions]) : nil))
        unless (action_name == 'show' &&
          current_user.has_access(controller_name,'viewer',strict:strict) &&
          (Object.const_get(controller_name.singularize.titleize).find(params[:id]).viewer_access rescue false))
          redirect_to errors_path
          return false
        end
      end
    end
  end

  def strict_access_validation
    access_validation(true) || current_user.global_admin?
  end


  def set_page_title
    module_name = case controller_name.titleize
    when 'Records' then 'Reports'
    when 'Reports' then 'Events'
    when 'Sms Actions' then 'Corrective Actions'
    when 'Sras' then 'SRAs'
    when 'Faa Reports' then 'FAA Reports'
    else controller_name.titleize end

    page_name = case action_name.titleize
    when 'Index' then 'Listing'
    else action_name.titleize end

    @title = "#{module_name} - #{page_name}"
  end


  def check_group(form)
    if session[:digest].present?
      return true
    end

    report = Object.const_get(form.titleize.gsub(/\s+/, '')).find(params[:id])
    if current_user.has_access("#{form}s", 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      true
    else
      group_validation = false #to reduce calculation of whether user is part of the group if present
      if report.privileges.present? && !report.privileges.reject(&:blank?).empty?
        current_user.privileges.each do |p|
          if report.get_privileges.include? p.id.to_s
            group_validation = true
          end
        end
      else
        group_validation = true
      end
      if (current_user.id == report.approver_id ||
          current_user.id == report.responsible_user_id) &&
          current_user.has_access("#{form}s",'view')
        redirect_to errors_path if !group_validation
      elsif defined?(report.viewer_access) &&
          report.viewer_access &&
          current_user.has_access("#{form}s",'viewer')
        redirect_to errors_path if !group_validation
      elsif current_user.id == report.created_by_id
        redirect_to errors_path if !group_validation
      elsif report.respond_to?(:tasks) && is_user_part_of_a_task(report)
        redirect_to errors_path if !group_validation
      elsif report.respond_to? :verifications
        validators_ids = report.verifications.map { |v| v.additional_validators }.flatten
        if validators_ids.include?(current_user.id.to_s)
          true
        else
          false
          redirect_to errors_path
        end
      else
        false
        redirect_to errors_path
      end
    end
  end


  def is_user_part_of_a_task(report)
    if report.tasks.present?
      report.tasks.each do |t|
        if t.res == current_user.id || t.app_id == current_user.id
          return true
        end
      end
    end
    false
  end


  def get_message_link(link_type, link_id)
    if link_type.present?


      case link_type
      when "Audit"
        audit_path(link_id)
      when "CorrectiveAction"
        corrective_action_path(link_id)
      when "Evaluation"
        evaluation_path(link_id)
      when "Finding"
        finding_path(link_id)
      when "Hazard"
        hazard_path(link_id)
      when "Im"
        im_path(link_id)
      when "Inspection"
        inspection_path(link_id)
      when "Investigation"
        investigation_path(link_id)
      when "Package"
        package_path(link_id)
      when "Recommendation"
        recommendation_path(link_id)
      when "Record"
        record_path(link_id)
      when "Report"
        report_path(link_id)
      when "Event"
        report_path(link_id)
      when "RiskControl"
        risk_control_path(link_id)
      when "SafetyPlan"
        safety_plan_path(link_id)
      when "SmsAction"
        sms_action_path(link_id)
      when "Sra"
        sra_path(link_id)
      when "Submission"
        submission_path(link_id)
      else
        nil
      end
    end
  end


  def notify_on_object_creation(owner)
    name_of_controller = controller_name
    object_type = owner.class.name
    if owner.class.name == 'SmsAction'
      object_title = 'Corrective Action (Safety Assurance)'
    elsif owner.class.name == 'CorrectiveAction'
      object_title = 'Corrective Action (Safety Reporting)'
    elsif owner.class.name == 'Recurrence'
      object_title = "Recurring #{owner.form_type}"
      name_of_controller = owner.form_type.downcase.pluralize
    else
      object_title = owner.class.name
    end

    notify_privileges = AccessControl.where(
      :action => 'notify',
      :entry  => name_of_controller)
      .map{|x| x.privileges.map(&:id)}.flatten
    notifiers = User.preload(:privileges)
      .where("disable is null or disable = 0")
      .keep_if{|x| x.privileges.map(&:id) & notify_privileges != []}

    call_rake 'notify',
      owner_type: object_type,
      owner_id: owner.id,
      subject: "New #{object_title} created in ProSafeT",
      users_id: notifiers.map(&:id)

  end


  #############################
  ####    SHARED FORMS     ####
  #############################

  def launch
    current_object = params[:controller].to_sym
    # @objects: list of object names that can be launched from the current object
    @objects =  CONFIG::LAUNCH_OBJECTS[current_object].map { |object|  object_class_and_table_name(object)  }
    render :partial => '/forms/workflow_forms/launch'
  end

  def launch_new_object
    parent_type = params[:parent_type].nil? ? params[:controller] : params[:parent_type]
    parent_id = params[:parent_id].nil? ? params[:id] : params[:parent_id]
    child = params[:child]
    template_id = params[:template_id]

    if child == 'submissions'
      redirect_to controller: child.pluralize, action: 'new', parent_type: parent_type, parent_id: parent_id, template: template_id, commit: 'Create'
    else
      redirect_to controller: child.pluralize, action: 'new', parent_type: parent_type, parent_id: parent_id
    end
  end

  def get_link_type
    @objects =  CONFIG::LINK_OBJECTS[params[:controller].to_sym].map { |object| object_class_and_table_name(object) }
    render :partial => '/forms/workflow_forms/get_link_type'
  end

  def show_items_to_link
    owner_object = Object.const_get(params[:controller].classify)
    owner = owner_object.find(params[:id])
    child_ids = owner.children.map{|child| child.child_id if child.child_type == params[:type].classify }.uniq.compact
    parents_ids = owner.parents.map{|parent| parent.parent_id if parent.parent_type == params[:type].classify }.uniq.compact
    ids_to_exclude = (parents_ids + child_ids + [owner.id]).join(", ")
    @items = owner_object.where("id NOT IN (#{ids_to_exclude})").select([:id, :title, :status])
    render :partial => "shared/show_items_to_link", locals: {item_type: params[:type].classify}
  end

  def add_links
    owner_class = params[:controller].classify
    owner_object = Object.const_get(owner_class)
    owner = owner_object.find(params[:id])
    item_type = params[:item_type].classify

    selected_ids = params[:items_selected].chomp(',').split(',').map{|id| id.to_i}
    selected_ids.each do |id|
      item = Object.const_get(item_type).find(id)
      c1 = Child.create({child_type: item_type, child_id: id, owner_type: owner_class, owner_id: owner.id})
      c2 = Child.create({child_type: owner_class, child_id: owner.id, owner_type: item_type, owner_id: id})
      owner.children << c1
      item.children << c2
      Transaction.build_for(item, "#{owner_class} Linked", current_user.id, "#{owner_class} ##{owner.id} linked to this #{item_type}")
    end
    message = "#{item_type} IDs ##{selected_ids.join(', ')} linked to this #{owner_class}"

    flash.now[:notice] = message
    Transaction.build_for(owner, "#{item_type} Linked", current_user.id, message)
    redirect_to eval("#{params[:controller].singularize}_path(owner)")
  end


  def unlink
    owner_class = params[:controller].classify
    owner_object = Object.const_get(owner_class)
    owner = owner_object.find(params[:id])
    item_type = params[:item_type].classify

    item_to_remove = Object.const_get(item_type).find(params[:item_id].to_i)
    Child.where(owner_type: owner_class, owner_id: owner.id, child_type: item_type, child_id: item_to_remove.id).first.destroy
    Child.where(owner_type: item_type, owner_id: item_to_remove.id, child_type: owner_class, child_id: owner.id).first.destroy
    Transaction.build_for(owner, "#{item_type} Unlinked", current_user.id, "#{item_type} ##{item_to_remove.id} unlinked from #{owner_class}")
    Transaction.build_for(item_to_remove, "#{owner_class} Unlinked", current_user.id, "#{owner_class} ##{owner.id} unlinked from #{item_type}")
    respond_to do |format|
      format.json {render :json => { :result => 'Removed'}}
    end
  end

  def set_parent_type_id(object)
    # if parent exists, set parent type and id
    @parent_type = params[:parent_type]
    @parent_id   = params[:parent_id]
  end

  def set_parent(object)
    if params[object][:parent_type].present? && params[object][:parent_id].present?
      @parent = Object.const_get(params[object][:parent_type].camelize.singularize).find(params[object][:parent_id])
    end

    params[object].except!(:parent_type)
    params[object].except!(:parent_id)
  end

  def create_parent_and_child(parent: parent, child: child)
    if parent.present?
      Child.create(child: child, owner:@parent)
      Parent.create(parent: parent, owner: child)
    end
  end

  # Handles permissions and ability to execute button actions
  def interpret
    op = params[:op].present? ? params[:op].symbolize_keys : {}
    begin
      unless CONFIG.check_action(current_user, params[:act].to_sym, @owner, **op)
        redirect_to eval("#{@class.name.underscore}_path(@owner)"),
          flash: {danger: "Unable to #{params[:commit] || params[:act]} #{@owner.class.titleize}."}
        return false
      end
    rescue
      redirect_to eval("#{@class.name.underscore}_path(@owner)"),
        flash: {danger: "Unknown process #{params[:act]}- action aborted."}
        return false
    end

    case params[:act].to_sym

    when :approve_reject # was approve route
      if @owner.class.name == 'Sra'
        @owner = Sra.find(params[:id]).becomes(Sra)
        pending_approval = @owner.status == 'Pending Approval'
        status = params[:commit].downcase == 'approve' ? ( pending_approval ? 'Completed' : 'Pending Approval') : 'Assigned'
        field = pending_approval ? :approver_comment : :reviewer_comment
        render :partial => '/forms/workflow_forms/process', locals: {status: status, field: field }
      else
        status = params[:commit] == 'approve' ? 'Completed' : 'Assigned'
        render partial: '/forms/workflow_forms/process', locals: {status: status}
      end

    when :assign # was assign route
      render partial: '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}

    when :attach_in_message
      redirect_to new_message_path(owner_id: @owner.id, owner_class: @owner.class)

    when :comment
      @comment = @owner.comments.new
      render partial: '/forms/viewer_comment'

    when :complete # was complete route
      status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
      case @class.name
      when 'Sra', 'Hazard', 'RiskControl'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :closing_comment}
      when 'Audit'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :comment}
      when 'Inspection'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :inspector_comment}
      when 'Evaluation'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :evaluator_comment}
      when 'Investigation'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :investigator_comment}
      when 'Finding'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :findings_comment}
      when 'SmsAction'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :sms_actions_comment}
      when 'Recommendation'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :recommendations_comment}
      when 'CorrectiveAction'
        render partial: '/forms/workflow_forms/process', locals: {status: status, field: :corrective_actions_comment}
      else
        render partial: '/forms/workflow_forms/process', locals: {status: status}
      end

    when :contact
      @contact = Contact.new
      render :partial => 'forms/contact_form'

    when :cost
      @cost = @owner.costs.new
      render :partial => 'forms/new_cost'

    # :delete handled safely by link_to in render_buttons

    # :edit handled safely by link_to in render_buttons

    # TODO - properly make the print functionality class ambiguous (applies for pdf and deid_pdf)
    when :pdf
      mod = session[:mode]
      # TODO - refactor SR and SMS IM printing
      owner_class_name = @owner.class.name
      name_mapping = CONFIG::OBJECT_NAME_MAP[owner_class_name]
      owner_name = name_mapping.present? ? name_mapping : owner_class_name
      # Only for SA and SRM
      if mod != 'ASAP' && mod != 'SMS IM' && mod != 'OSHA'
        # begin action specific behavior
        print_special_matrix(@owner) if owner_class_name == 'Hazard'
        # end
        @deidentified = params[:deidentified]
        @meta_field_args = ['show']
        @meta_field_args << 'admin' if current_user.global_admin?
        html = render_to_string(:template=>"/pdfs/print.html.slim")
        pdf_options = {
          header_html:  'app/views/pdfs/print_header.html',
          header_spacing:  1,

          header_right: '[page] of [topage]'
        }
        if CONFIG::GENERAL[:has_pdf_header]
          pdf_options[:header_html] =  "app/views/pdfs/#{AIRLINE_CODE}/print_header.html"
        end
        if CONFIG::GENERAL[:has_pdf_footer]
          pdf_options.merge!({
            footer_html:  "app/views/pdfs/#{AIRLINE_CODE}/print_footer.html",
            footer_spacing:  3,
          })
        end
        pdf = PDFKit.new(html, pdf_options)
        pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
        pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
        filename = "#{owner_name}_#{@owner.get_id}" + (@deidentified ? '(de-identified)' : '')
        send_data pdf.to_pdf, :filename => "#{filename}.pdf"
      else
        redirect_to eval("print_#{owner_class_name.underscore}_path(@owner, format: :pdf, deidentified: params[:deidentified])")
        return false
      end

    when :deid_pdf
      mod = session[:mode]
      # TODO - refactor SR and SMS IM printing
      owner_class_name = @owner.class.name
      name_mapping = CONFIG::OBJECT_NAME_MAP[owner_class_name]
      owner_name = name_mapping.present? ? name_mapping : owner_class_name
      # Only for SA and SRM
      if mod != 'ASAP' && mod != 'SMS IM' && mod != 'OSHA'
        # begin action specific behavior
        print_special_matrix(@owner) if owner_class_name == 'Hazard'
        # end
        @deidentified = params[:deidentified]
        @meta_field_args = ['show']
        @meta_field_args << 'admin' if current_user.global_admin?
        html = render_to_string(:template=>"/pdfs/print.html.slim")
        pdf_options = {
          header_html:  'app/views/pdfs/print_header.html',
          header_spacing:  1,

          header_right: '[page] of [topage]'
        }
        if CONFIG::GENERAL[:has_pdf_header]
          pdf_options[:header_html] =  "app/views/pdfs/#{AIRLINE_CODE}/print_header.html"
        end
        if CONFIG::GENERAL[:has_pdf_footer]
          pdf_options.merge!({
            footer_html:  "app/views/pdfs/#{AIRLINE_CODE}/print_footer.html",
            footer_spacing:  3,
          })
        end
        pdf = PDFKit.new(html, pdf_options)
        pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
        pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
        filename = "#{owner_name}_#{@owner.get_id}" + (@deidentified ? '(de-identified)' : '')
        send_data pdf.to_pdf, :filename => "#{filename}.pdf"
      else
        redirect_to eval("print_#{owner_class_name.underscore}_path(@owner, format: :pdf, deidentified: params[:deidentified])")
        return false
      end
    # :finding redirect handled in render_buttons

    # :hazard redirect handled in render_buttons

    when :reopen
      @owner.update_attribute(:status, 'New')
      Transaction.build_for(@owner, 'Reopen', current_user.id)
      redirect_to eval("#{@class.name.underscore}_path(@owner)"),
        flash: {success: " #{@owner.class.titleize} Reopened."}

    when :sign
      @signature = Signature.new
      render partial: 'forms/signatures/sign'

    when :task
      load_options
      @task = @owner.tasks.new
      render :partial => 'forms/task'

      #message submitter, override status, private link, reopen

    when :request_extension
      @extension_request = @owner.extension_requests.new
      @extension_request.requester = current_user
      @extension_request.approver = @owner.approver
      @extension_request.request_date = Time.now
      render :partial => 'extension_requests/new'

    when :schedule_verification
      @verification = @owner.verifications.new
      @verification.validator = @owner.responsible_user
      render :partial => 'verifications/new'

    else
      redirect_to eval("#{@class.name.underscore}_path(@owner)"),
        flash: {danger: 'Unknown process- action aborted.'}
    end
  end

  def display_signature(owner)
    if owner.class.name == 'Signature'
      send_file owner.path.current_path, type: 'image/png', disposition: 'inline'
    end
  end


  def keep_privileges(privilege, type)
    rule = AccessControl.where("action=? and entry=?", 'index', type)
    if rule.present?
      access = rule.first
      all_access = privilege.access_controls
      (access.list_type && (all_access.include? access))||(!access.list_type && !(all_access.include? access))
    else
      true
    end
  end



  def display_asapcar(car)
    if car.report.present?
      return display_in_table(car.report)
    else
      return true
    end
  end



  def display_in_table(report)
    if current_user.global_admin?
      return true
    elsif (report.privileges || []).reject{|priv| priv.empty?}.present?
      current_user.privileges.each do |p|
        if report.get_privileges.include? p.id.to_s
          return true
        end
      end
      return false
    else
      return true
    end
  end

  def get_car_owner(car)
    case car.owner_type
      when 'Finding'
        return car.owner.get_owner rescue Finding.where(obj_id: car.owner_obj_id)
      when 'Investigation'
        return 'investigations'
    end
  end

  def display_finding(finding)
    if finding.type == "AuditFinding"
      return current_user.has_access("audits", "index")
    elsif finding.type == "InspectionFinding"
      return current_user.has_access("inspections", "index")
    elsif finding.type == "EvaluationFinding"
      return current_user.has_access("evaluations", "index")
    elsif finding.type == "InvestigationFinding"
      return current_user.has_access("investigations", "index")
    else
      return true
    end
  end

  def display_car(car)
    if car.type == "FindingAction"
      return display_finding(car.finding)
    elsif car.type == "InvestigationAction"
      return current_user.has_access("investigations", "index")
    else
      return true
    end
  end

  def display_recommendation(rec)
    if rec.type == "FindingRecommendation"
      return display_finding(rec.finding)
    elsif rec.type == "InvestigationRecommendation"
      return current_user.has_access("investigations", "index")
    else
      return true
    end
  end

  def get_recommendation_owner(rec)
    if rec.owner_type.nil?
      return ""
    end
    case rec.owner_type
    when 'Finding'
      return rec.owner.get_owner
    else
      return "#{rec.owner_type.downcase}s"
    end
  end


  def submission_display(report)
    true
    # if (current_user.has_template_access(report.template.name).include? "viewer_template_id") || (current_user == report.created_by) || (current_user.has_template_access(report.template.name).include? "viewer_template_deid")
    #   return true
    # else
    #   return false
    # end
  end

  def record_display(report)
    true
    # if (current_user.has_template_access(report.template.name).include? "viewer_template_id") || (current_user == report.created_by) || ((current_user.has_template_access(report.template.name).include? "viewer_template_deid") && report.viewer_access)
    #   return true
    # else
    #   return false
    # end
  end

  def adjust_session
    # TEMP
    if CONFIG::GENERAL[:osha_visibility]
      load_controller_list
      if params[:type].present? && params[:type].include?('Osha')
        session[:mode] = 'OSHA'
      elsif @sms_list.include? controller_name
        session[:mode] = 'SMS'
      elsif @sms_im_list.include? controller_name
        session[:mode] = 'SMS IM'
      elsif @asap_list.include? controller_name
        is_osha_module = params[:id].present? && Object.const_get(params[:controller].classify).find(params[:id]).class.name.include?('Osha')
        if is_osha_module
          session[:mode] = 'OSHA'
        else
          session[:mode] = 'ASAP'
        end
      elsif @srm_list.include? controller_name
        session[:mode] = 'SRM'
      end
    else
      load_controller_list
      if @sms_list.include? controller_name
        session[:mode] = 'SMS'
      elsif @sms_im_list.include? controller_name
        session[:mode] = 'SMS IM'
      elsif @asap_list.include? controller_name
        session[:mode] = 'ASAP'
      elsif @srm_list.include? controller_name
        session[:mode] = 'SRM'
      end
    end
    true
  end


  def get_classes_by_module
    case session[:mode]
    when 'SMS'
      ['Audit','Evaluation','Inspection','Investigation','Finding','Recommendation']
    when 'ASAP'
      {'Submission'=>"Submission",'Report'=>"Record"}
    when 'SRM'
      {'SRM/SRA'=>"Sra",'Hazard'=>'Hazard'}
    else
      []
    end
  end


  def get_fields_by_class
    case session[:mode]
    when 'SMS'
      {
        'Audit'=>{
          "Department"=>"department",
          "Audit Type"=>"audit_type",
          'Location'=>"location",
          'Vendor'=>'vendor',
          'Audit Department'=>'audit_department',
          'Process'=>'process',
          'Supplier'=>'supplier',
          'Status'=>'status'
        },
        'Evaluation'=>{
          "Department"=>"department",
          "Audit Type"=>"evaluation_type",
          'Location'=>"location",
          'Vendor'=>'vendor',
          'Evaluation Department'=>'evaluation_department',
          'Process'=>'process',
          'Supplier'=>'supplier',
          'Status'=>'status'
        },
        'Inspection'=>{
          "Department"=>"department",
          "Inspection Type"=>"inspection_type",
          'Location'=>"location",
          'Vendor'=>'vendor',
          'Inspection Department'=>'inspection_department',
          'Process'=>'process',
          'Supplier'=>'supplier',
          'Status'=>'status'
        },
        'Investigation'=>{
          'Investigation Type'=>"inv_type",
          'Source'=>'source',
          'NTSB'=>'ntsb',
          'Safety Hazard'=>'safety_hazard',
          'Likelihood(Baseline)'=>"likelihood",
          'Severity(Baseline)'=>"severity",
          'Risk Factor(Baseline)'=>"risk_factor",
          "Likelihood(Mitigated)"=>"likelihood_after",
          "Severity(Mitigated)"=>"severity_after",
          "Risk Factor(Mitigated)"=>"risk_factor_after",
          'Status'=>'status'
        },
        'Finding'=>{
          'Regulatory Violation'=>"regulatory_violation",
          'Policy Violation'=>"policy_violation",
          'Safety'=>"safety",
          'Classification'=>"classification",
          'Repeat'=>'repeat',
          "Immediate Action"=>"immediate_action",
          "Department"=>'department',
          "Authority"=>'authority',
          "Controls"=>"controls",
          "Interfaces"=>'interfaces',
          "Policy"=>"policy",
          "Procedures"=>"procedures",
          "Process Measures"=>"process_measures",
          "Responsibility"=>"responsibility",
          'Likelihood(Baseline)'=>"likelihood",
          'Severity(Baseline)'=>"severity",
          'Risk Factor(Baseline)'=>"risk_factor",
          "Likelihood(Mitigated)"=>"likelihood_after",
          "Severity(Mitigated)"=>"severity_after",
          "Risk Factor(Mitigated)"=>"risk_factor_after",
          "Status"=>"status"
        },
        'Recommendation'=>{
          'Status'=>"status",
          'Department'=>'department',
          "Immediate Action"=>'immediate_action',
          "Recommended Action"=>"recommended_action"
        }
      }
    when 'SRM'
      {
        'Sra'=>{
          'Type of Change'=>"type_of_change",
          'Likelihood(Baseline)'=>"likelihood",
          'Severity(Baseline)'=>"severity",
          'Risk Factor(Baseline)'=>"risk_factor",
          "Likelihood(Mitigated)"=>"likelihood_after",
          "Severity(Mitigated)"=>"severity_after",
          "Risk Factor(Mitigated)"=>"risk_factor_after"
        },
        'Hazard'=>{
          'Likelihood(Baseline)'=>"likelihood",
          'Severity(Baseline)'=>"severity",
          'Risk Factor(Baseline)'=>"risk_factor",
          "Likelihood(Mitigated)"=>"likelihood_after",
          "Severity(Mitigated)"=>"severity_after",
          "Risk Factor(Mitigated)"=>"risk_factor_after",
          "Status"=>"status"
        }
      }
    else
      []
    end


  end



  # Deals with Advanced Search for different types of reports, such as Events, Corrective Actions, Audits, SRAs, etc
  def handle_search
    @terms = @table.get_meta_fields('index')
    if @table == Query
      @records = @table.where(target: @types.values - ['SmsTask']).includes(:created_by)
      sms_task_queries = @table.where(target: 'SmsTask').includes(:created_by)
      @records += filter_task_queries_for_current_module(sms_task_queries)
    elsif @table == Meeting
      @records = @table.includes(:invitations, :host).where('meetings.type is null')
      unless current_user.has_access('meetings', 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true )
        @records = @records.where('(participations.users_id = ? AND participations.status in (?)) OR hosts_meetings.users_id = ?',
          current_user.id, ['Pending', 'Accepted'], current_user.id)
      end
      @records.keep_if{|r| display_in_table(r)}
    elsif @table == SrmMeeting
      @records=SrmMeeting.includes(:invitations, :host)
      unless current_user.has_access('srm_meetings', 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
        @records = @records.where('(participations.users_id = ? AND participations.status in (?)) OR hosts_meetings.users_id = ?',
          current_user.id, ['Pending', 'Accepted'], current_user.id)
      end
    else
      @records = @table.within_timerange(params[:start_date], params[:end_date])
    end
    if params[:type].present?
      begin #TODO: Resolve issues with IM not having owner_type defined (non-polymorphic elements in IM); keep begin block and remove rescue at that point
        @records = @records.select{|x| x.owner_type == params[:type]}
      rescue
        @records = @records.select{|x| x.type == params[:type]}
      end
    end
    if params[:status].present? && params[:status] != 'All'
      if params[:status] == "Overdue"
        @records = @records.select{|x| x.overdue}
      else
        @records = @records.select{|x| x.status == params[:status]}
      end
    end
    if params[:advance_search].present?
      if params[:searchterm_1].present?
        if params[:field_1].present?
          field = @terms.select{|header| header[:field] == params[:searchterm_1]}.first
          if field[:type] == 'user'
            params[:searchterm_1] = "get_submitter_id" if params[:searchterm_1] == "get_submitter_name"

            params[:field_1] = User.where('full_name LIKE ?', '%' + params[:field_1] + '%').map{|x| x.id}
            @records.keep_if{|r| params[:field_1].include? r.send(params[:searchterm_1])}
          elsif field[:type] == 'boolean_box'
            @records.keep_if{|r| (r.send(params[:searchterm_1]) ? 'yes' : 'no') == params[:field_1].downcase}
          else
            @records.keep_if{|r| r.send(params[:searchterm_1]).to_s.downcase.include? params[:field_1].downcase}
          end
        elsif params[:start_date_1].present? && params[:end_date_1].present?
          start_date = params[:start_date_1].to_date
          end_date = params[:end_date_1].to_date
          @records.keep_if {|r| r.send(params[:searchterm_1]).to_datetime.between?(start_date.beginning_of_day, end_date.end_of_day) rescue false}
        end
      end
      if params[:searchterm_2].present?
        if params[:field_2].present?
          field = @terms.select{|header| header[:field] == params[:searchterm_2]}.first
          if field[:type] == 'user'
            params[:searchterm_2] = "get_submitter_id" if params[:searchterm_2] == "get_submitter_name"
            params[:field_2] = User.where('full_name LIKE ?', '%' + params[:field_2] + '%').map{|x| x.id}
            @records.keep_if{|r| params[:field_2].include? r.send(params[:searchterm_2])}
          else
            @records.keep_if{|r| r.send(params[:searchterm_2]).to_s.downcase.include? params[:field_2].downcase}
          end
        elsif params[:start_date_2].present? && params[:end_date_2].present?
          start_date = params[:start_date_2].to_date
          end_date = params[:end_date_2].to_date
          @records.keep_if {|r| r.send(params[:searchterm_2]).to_datetime.between?(start_date.beginning_of_day, end_date.end_of_day) rescue false}
        end
      end

      if params[:searchterm_3].present?
        if params[:field_3].present?
          field = @terms.select{|header| header[:field] == params[:searchterm_3]}.first
          if field[:type] == 'user'
            params[:searchterm_3] = "get_submitter_id" if params[:searchterm_3] == "get_submitter_name"
            params[:field_3] = User.where('full_name LIKE ?', '%' + params[:field_3] + '%').map{|x| x.id}
            @records.keep_if{|r| params[:field_3].include? r.send(params[:searchterm_3])}
          else
            @records.keep_if{|r| r.send(params[:searchterm_3]).to_s.downcase.include? params[:field_3].downcase}
          end
        elsif params[:start_date_3].present? && params[:end_date_3].present?
          start_date = params[:start_date_3].to_date
          end_date = params[:end_date_3].to_date
          @records.keep_if {|r| r.send(params[:searchterm_3]).to_datetime.between?(start_date.beginning_of_day, end_date.end_of_day) rescue false}
        end
      end

      if params[:searchterm_4].present?
        if params[:field_4].present?
          field = @terms.select{|header| header[:field] == params[:searchterm_4]}.first
          if field[:type] == 'user'
            params[:searchterm_4] = "get_submitter_id" if params[:searchterm_4] == "get_submitter_name"
            params[:field_4] = User.where('full_name LIKE ?', '%' + params[:field_4] + '%').map{|x| x.id}
            @records.keep_if{|r| params[:field_4].include? r.send(params[:searchterm_4])}
          else
            @records.keep_if{|r| r.send(params[:searchterm_4]).to_s.downcase.include? params[:field_4].downcase}
          end
        elsif params[:start_date_4].present? && params[:end_date_4].present?
          start_date = params[:start_date_4].to_date
          end_date = params[:end_date_4].to_date
          @records.keep_if {|r| r.send(params[:searchterm_4]).to_datetime.between?(start_date.beginning_of_day, end_date.end_of_day) rescue false}
        end
      end
    end
  end




  def load_controller_list
    @sms_list=['sms_actions','findings','audits','inspections','recommendations','investigations','evaluations']
    @sms_im_list=['ims']
    # @asap_list=['reports','records','corrective_actions','trackings','faa_reports','templates','fields']
    @asap_list=['submissions','reports','records','corrective_actions','trackings','faa_reports']
    @srm_list=['sras','hazards','risk_controls','safety_plans']
  end

  def send_session
    accessor = instance_variable_get(:@_request)
    ActiveRecord::Base.send(:define_method, "session", proc {accessor.session})
  end
  # Find the admin user for an airport using its code (case insensitive)
  #
  # Ex: airport_admin("SMX") => #<User username: "prodigiq_smx_admin", module_access: "...">
  def airport_admin(code)
    User.find_by_username("prodigiq_#{code.downcase}_admin")
  end
  # Boolean indicating whether or not an airport can access a specific module
  #
  # Ex: airport_has_access?("SMX", "maint") => true
  # def airport_has_access?(code, module_name)
  #   airport_admin(code).module_access.include?(module_name)
  # end

  # Find the admin user for the current user's airport
  def current_airport_admin
    @current_admin ||= airport_admin(current_user.airport)
  end



  # Reopen a report (applicable to Audits, Inspections, Evaluation, Investigations, Findings, Sms_actions, Recommendations )
  def reopen_report(owner)
    owner_class = owner.class.name
    owner.status = "New"
    owner.close_date = nil
    owner.save
    Transaction.build_for(
      owner,
      'Reopen',
      current_user.id
    )
    redirect_to eval("#{owner_class.underscore}_path(owner)") rescue return
  end


  def send_notification(owner, commit)
    object_name = owner.is_a?(SmsAction) ? 'Corrective Action' : owner.class.name.titleize
    case commit
    when 'Reassign'
      notify(owner,
        notice: {
          users_id: owner.responsible_user_id,
          content: "#{object_name} ##{owner.get_id} has been Reassigned to you."},
        mailer: true,
        subject: "#{object_name} Reassigned")
    when 'Assign'
      notify(owner,
        notice: {
          users_id: owner.responsible_user.id,
          content: "#{object_name} ##{owner.id} has been assigned to you."},
        mailer: true,
        subject: "#{object_name} Assigned")
    when 'Complete'
      notify(owner,
        notice: {
          users_id: owner.approver.id,
          content: "#{object_name} ##{owner.id} needs your Approval."},
        mailer: true,
        subject: "#{object_name} Pending Approval") if owner.approver.present?
    when 'Reject'
      if owner.responsible_user.present?
        notify(owner,
          notice: {
            users_id: owner.responsible_user.id,
            content: "#{object_name} ##{owner.id} was Rejected by the Final Approver."},
          mailer: true,
          subject: "#{object_name} Rejected") if owner.approver.present?
      end
    when 'Approve'
      if owner.responsible_user.present?
        notify(owner,
        notice: {
          users_id: owner.responsible_user.id,
          content: "#{object_name} ##{owner.id} was Approved by the Final Approver."},
        mailer: true,
        subject: "#{object_name} Approved") if owner.approver.present?
      end
    end
  end


  # sample arg => notice: {users_id: 1, content: 'Audit is assigned'}, mailer: true, subject: 'Audit Assigned'
  def notify(record, arg)
    if arg[:notice][:users_id].present? &&
        User.find(arg[:notice][:users_id]).present? &&
        record.present? && record.respond_to?(:notices)
      notice = record.notices.create(arg[:notice])
      puts "NOTICE OWNER TYPE NULL" if notice.owner_type.nil?
      if arg[:mailer]
        if arg[:extra_attachments].present?
          NotifyMailer.notify(notice, arg[:subject], record, arg[:attachment], arg[:extra_attachments])
        else
          NotifyMailer.notify(notice, arg[:subject], record, arg[:attachment], 0)
        end
      end
    end
  end


  def denotify(user,owner,action)
    if user.present?
      owner.notices.where('users_id = ? and action = ?', user.id, action).each(&:destroy)
    end
  end
  helper_method :airport_admin, :airport_has_access?, :current_airport_admin


  def get_dataset
    object_name =  params[:controller].classify

    case object_name
    when 'Submission'
      if session[:mode] == 'OSHA'
        render json: OshaSubmissionDatatable.new(view_context, current_user)
      else
        render json: SubmissionDatatable.new(view_context, current_user)
      end
    when 'Record', 'Report'
      render json: SafetyReportingDatatable.new(view_context, current_user)
      # render json: OshaRecordDatatable.new(view_context, current_user)
    when 'CorrectiveAction'
      render json: CorrectiveActionDatatable.new(view_context, current_user)
    when 'Query'
      render json: QueryDatatable.new(view_context, current_user)
    when 'Checklist'
      render json: ChecklistDatatable.new(view_context, current_user)
    when 'Finding'
      render json: FindingDatatable.new(view_context, current_user)
    else # SA, SRA modules
      render json: ApplicationDatatable.new(view_context, current_user)
    end
  end


  def filter_records(object_name, controller_name)
    if %w[Audit Inspection Evaluation Investigation].include? object_name
      @records = @records.keep_if{|x| x[:template].nil? || !x[:template]}
      if !current_user.has_access(controller_name,'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
        cars =  Object.const_get(object_name).where('status in (?) and responsible_user_id = ?',
          ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
        cars +=  Object.const_get(object_name).where('approver_id = ?',  current_user.id)
        if current_user.has_access(controller_name,'viewer')
           Object.const_get(object_name).where('viewer_access = true').each do |viewable|
            if viewable.privileges.blank?
              cars += [viewable]
            else
              viewable.privileges.each do |privilege|
                current_user.privileges.include? privilege
                cars += [viewable]
              end
            end
          end
        end
        cars +=  Object.const_get(object_name).where('created_by_id = ?', current_user.id)
        @records = @records & cars
      end
    else # Findings, Corrective Actions, Recommendations
      if !current_user.has_access(controller_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
        cars = Object.const_get(object_name).where('status in (?) and responsible_user_id = ?',
          ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
        cars += Object.const_get(object_name).where('approver_id = ?', current_user.id)
        cars += Object.const_get(object_name).where('created_by_id = ?', current_user.id)
        @records = @records & cars
      end
    end
  end

  # http://railscasts.com/episodes/127-rake-in-background
  def call_rake(task, options={})
    options[:rails_env] = Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'"}
    Rails.logger.info "running `rake #{task} #{args.join(' ')} --trace >> #{Rails.root}/log/rake.log &`"

    if Rails.env.production?
      system "/usr/local/bin/bundle exec /usr/local/bin/rake #{task} #{args.join(' ')} --trace >> #{Rails.root}/log/rake.log &"
    else
      system "rake #{task} #{args.join(' ')} --trace >> #{Rails.root}/log/rake.log &"
    end
  end


  def convert_from_risk_value_to_risk_index
    if CONFIG::GENERAL[:drop_down_risk_selection]
      risk_table    = CONFIG::MATRIX_INFO[:risk_table]
      column_header = risk_table[:column_header]
      row_header  = risk_table[:row_header]
      object_name = self.class.name.gsub('Controller', '').underscore.singularize

      if params[object_name][:risk_factor].present?
        severity_value    = params[object_name][:severity]
        probability_value = params[object_name][:likelihood]
        params[object_name][:severity]   = row_header.find_index(severity_value)
        params[object_name][:likelihood] = column_header.find_index(probability_value)
      end

      if params[object_name][:risk_factor_after].present?
        severity_after_value    = params[object_name][:severity_after]
        probability_after_value = params[object_name][:likelihood_after]
        params[object_name][:severity_after]   = row_header.find_index(severity_after_value)
        params[object_name][:likelihood_after] = column_header.find_index(probability_after_value)
      end
    end
  end


  # save records through ajax call
  def ajax_update
    object_name = self.class.name.gsub('Controller', '').underscore.singularize
    class_name = self.class.name.gsub('Controller', '').singularize
    @owner = Object.const_get(class_name).find(params[:id])
    case params[:commit]
    when 'Save Fields'
      if params[:record][:record_fields_attributes].present?
        params[:record][:record_fields_attributes].each_value do |field|
          if field[:value].is_a?(Array)
            field[:value].delete("")
            field[:value] = field[:value].join(";")
          end
        end
      end

      # @owner.update_attributes(params[object_name.to_sym])
      # @record = @owner
      # category = Category.find(params[:category_id])
      # fields = category.fields
      # @record_fields_hash = RecordField.preload(:field).where(records_id: @record.id).nonempty.group_by(&:field)
      # render partial: 'records/show_category', locals: {category: category, fields: fields}
      @owner.update_attributes(params[object_name.to_sym])
      # @record = @owner
      @record = Object.const_get(class_name).find(params[:id])
      @cat = Category.find(params[:category_id])
      render partial: 'records/category',
             locals: {deid: !current_user.has_template_access(@record.template.name).include?('viewer_template_id'),
             from_record_show: true,
             record_edit_access: current_user.has_access('records', 'edit', admin: CONFIG::GENERAL[:global_admin_default]),
             hide_panel_head: true}
    else
      if params[:ajax_call]
        convert_from_risk_value_to_risk_index
        @owner.update_attributes(params[object_name.to_sym])
        load_special_matrix(@owner)
        render partial: 'risk_matrices/panel_matrix/show_matrix/matrix_content'
      end
    end

  end


  private

  def set_last_seen_at
    begin
      current_user.update_attribute(:last_seen_at, Time.current)
      session[:last_seen_at] = Time.current
    rescue
    end
  end

end
