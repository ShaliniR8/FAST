if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end
end


class SrasController < ApplicationController

  before_filter :set_table_name, :login_required
  before_filter :load_options
  before_filter :define_owner, only: [:show, :interpret]

  before_filter(only: [:new])    {set_parent_type_id(:sra)}
  before_filter(only: [:create]) {set_parent(:sra)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @sra)}

  def define_owner
    @class = Object.const_get('Sra')
    @owner = Sra.find(params[:id])
  end


  def set_table_name
    @table_name = "sras"
  end


  # def index
  #   # @title = "SRAs"
  #   # @table = Object.const_get("Sra")
  #   # @headers = @table.get_meta_fields('index')
  #   # @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
  #   # handle_search
  #   # filter_sras

  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   if params[:advance_search].present?
  #     handle_search
  #   else
  #     @records = records
  #   end
  #   filter_sras
  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_hash['Overdue'] = records.select{|x| x.overdue}
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def new
    load_options
    @fields = Sra.get_meta_fields('form')
    @risk_groups = RiskMatrixGroup.find(:all)
    @sra = Sra.new
    @owner = @sra
    #form_special_matrix(@sra, "sra", "severity_extra", "probability_extra")
    if params[:record].present?
      @record = Record.find(params[:record])
    end
    @cancel_path = root_url
    if @record.present?
      @cancel_path = record_path(@record)
    end
  end


  def create
    @sra = Sra.create(params[:sra])
    @sra.status = 'New'
    @sra.viewer_access = true if CONFIG.srm::GENERAL[:enable_sra_viewer_access]
    message = "SRA (SRM) created."

    if params[:matrix_id].present?
      connection = SraMatrixConnection.create(
        :matrix_id => params[:matrix_id],
        :owner_id => @sra.id)
      connection.save
    end
    if @sra.save
      if CONFIG.srm::GENERAL[:one_page_sra].present? && params[:create_hazard_risk_control].present? && params[:create_hazard_risk_control].to_i == 1
        hazard = Hazard.new
        hazard.status = 'New'
        hazard.title = params[:hazard_title]
        hazard.due_date = params[:hazard_completion_date]
        hazard.description = params[:hazard_description]
        hazard.sra_id = @sra.id
        hazard.created_by_id = params[:sra][:created_by_id]
        hazard.responsible_user_id = params[:sra][:responsible_user_id]
        hazard.approver_id = params[:sra][:approver_id]

        hazard.save
        notify_on_object_creation(hazard)

        risk_control = RiskControl.new
        risk_control.status = 'New'
        risk_control.title = params[:risk_title]
        risk_control.due_date = params[:risk_completion_date]
        risk_control.description = params[:risk_description]
        risk_control.hazard_id = hazard.id
        risk_control.created_by_id = params[:sra][:created_by_id]
        risk_control.responsible_user_id = params[:sra][:responsible_user_id]
        risk_control.approver_id = params[:sra][:approver_id]

        risk_control.save
        notify_on_object_creation(risk_control)

        message = "SRA (SRM) created along with associated Hazard and Risk Control."
      end
      notify_on_object_creation(@sra)
      redirect_to sra_path(@sra), flash: {success: message}
    end
  end



  def update
    transaction = true
    @owner = Sra.find(params[:id]).becomes(Sra)
    sra_meeting = @owner.meeting
    meeting_redirect = false
    transaction_content = params[:sra][:closing_comment] rescue nil
    if transaction_content.nil?
      if params[:sra][:comments_attributes].present?
        params[:sra][:comments_attributes].each do |key, val|
          transaction_content = val[:content] rescue nil
        end
      end
    end

    case params[:commit]
    when 'Assign'
      @owner.update_attributes(params[:sra])
      notify(@owner,
        notice: {
          users_id: @owner.responsible_user.id,
          content: "SRA ##{@owner.id} has been assigned to you."},
        mailer: true,
        subject: 'SRA Assigned')
    when 'Complete'
      if @owner.reviewer
        notify(@owner,
          notice: {
            users_id: @owner.reviewer.id,
            content: "SRA ##{@owner.id} needs your Review."},
          mailer: true,
          subject: 'SRA Pending Review')
        update_status = 'Pending Review'
      elsif @owner.approver
        update_status = 'Pending Approval'
        notify(@owner,
          notice: {
            users_id: @owner.approver.id,
            content: "SRA ##{@owner.id} needs your Approval."},
          mailer: true,
          subject: 'SRA Pending Approval')
      else
        @owner.close_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      if @owner.status == 'Pending Review'
        update_status = 'Assigned'
        notify(@owner,
          notice: {
            users_id: @owner.responsible_user.id,
            content: "SRA ##{@owner.id} was Rejected by the Quality Reviewer."},
          mailer: true,
          subject: 'SRA Rejected') if @owner.responsible_user
        transaction_content = "Rejected by the Quality Reviewer with comment #{params[:sra][:reviewer_comment] rescue ""}"
      else
        update_status = 'Assigned'
        notify(@owner,
          notice: {
            users_id: @owner.responsible_user.id,
            content: "SRA ##{@owner.id} was Rejected by the Final Approver."},
          mailer: true,
          subject: 'SRA Rejected') if @owner.responsible_user
        transaction_content = "Rejected by the Final Approver with comment #{params[:sra][:approver_comment] rescue ""}"
      end
    when 'Approve'
      # if !@owner.approver #Approved by reviewer with absent approver case
      #   update_status = 'Completed'
      #   @owner.close_date = Time.now
      #   notify(@owner,
      #     notice: {
      #       users_id: @owner.responsible_user.id,
      #       content: "SRA ##{@owner.id} was Approved by the Quality Reviewer."},
      #     mailer: true,
      #     subject: 'SRA Approved') if @owner.responsible_user
      #   transaction_content = 'Approved by the Quality Reviewer'
      # elsif @owner.status == 'Pending Review' #We update status after the switch case; this is the old status we compare
      #   update_status = 'Pending Approval'
      #   notify(@owner,
      #     notice: {
      #       users_id: @owner.responsible_user.id,
      #       content: "SRA ##{@owner.id} needs your Approval."},
      #     mailer: true,
      #     subject: 'SRA Pending Approval') if @owner.responsible_user
      #   transaction_content = 'Approved by the Quality Reviewer'
      # else
      #   @owner.close_date = Time.now
      #   notify(@owner,
      #     notice: {
      #       users_id: @owner.responsible_user.id,
      #       content: "SRA ##{@owner.id} was Approved by the Final Approver."},
      #     mailer: true,
      #     subject: 'SRA Approved')
      #   transaction_content = 'Approved by the Final Approver'
      # end


      if @owner.status == 'Pending Review' #We update status after the switch case; this is the old status we compare
        send_notice = false
        @owner.close_date = Time.now
        if @owner.approver
          send_notice = true
          next_user_id = @owner.approver.id
          update_status = 'Pending Approval'
          notice_content = "SRA ##{@owner.id} needs your Approval."
        else
          next_user_id = @owner.responsible_user.id if @owner.responsible_user
          send_notice = true if @owner.responsible_user
          update_status = 'Completed'
          notice_content = "SRA ##{@owner.id} was approved by the Quality Reviewer."
        end
        notify(@owner,
          notice: {
            users_id: next_user_id,
            content: notice_content},
          mailer: true,
          subject: 'SRA Approved') if send_notice
        transaction_content = "Approved by the Quality Reviewer with comment #{params[:sra][:reviewer_comment] rescue ""}"
      else
        @owner.close_date = Time.now
        notify(@owner,
          notice: {
            users_id: @owner.responsible_user.id,
            content: "SRA ##{@owner.id} was Approved by the Final Approver."},
          mailer: true,
          subject: 'SRA Approved') if @owner.responsible_user
        transaction_content = "Approved by the Final Approver with comment #{params[:sra][:approver_comment] rescue ""}"
      end
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:sra][:status]}"
      params[:sra][:close_date] = params[:sra][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    when 'Add Meeting Minutes'
      meeting_redirect = true
      Transaction.build_for(
        sra_meeting,
        params[:commit],
        current_user.id,
        "SRA ##{@owner.get_id}"
      )
    end
    @owner.update_attributes(params[:sra])
    @owner.status = update_status || @owner.status #unless otherwise specified, use default status update from views
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.save
    redirect_to meeting_redirect ? meeting_path(sra_meeting) : sra_path(@owner)
  end



  def show
    @has_status = true
    @root_cause_headers = HazardRootCause.get_headers
    @description_headers = Cause.get_meta_fields('show')
    @agenda_headers = SrmAgenda.get_headers
    @sra = Sra.find(params[:id])

    related_user_ids = []
    related_user_ids << @sra.created_by_id
    if @sra.responsible_user_id.present?
      related_user_ids << @sra.responsible_user_id
    end
    if @sra.reviewer_id.present?
      related_user_ids << @sra.reviewer_id
    end
    if @sra.approver_id.present?
      related_user_ids << @sra.approver_id
    end
    if @sra.tasks.present?
      @sra.tasks.each do |t|
        if t.res.present?
          related_user_ids << t.res
        end
        if t.app_id.present?
          related_user_ids << t.app_id
        end
      end
    end

    has_access = false
    if current_user.has_access('sras', 'viewer', admin: CONFIG::GENERAL[:global_admin_default]) && @sra.viewer_access.present?
      has_access = true
    else
      has_access = current_user.has_access('sras', 'show', admin: CONFIG::GENERAL[:global_admin_default]) &&
                   (related_user_ids.include?(current_user.id) ||
                   current_user.has_access('sras', 'admin', admin: CONFIG::GENERAL[:global_admin_default]))
    end

    redirect_to errors_path unless has_access

    @records = @sra.children.present? ? Record.where(id: @sra.children.map(&:child_id)) : []
    @risk_group = @sra.matrix_connection.present? ? @sra.matrix_connection.matrix_group : ''
    @owner = @sra
    load_options
    load_special_matrix(@sra)
    @fields = Sra.get_meta_fields('show')
  end


  def mitigate
    @owner = Sra.find(params[:id])
    @risk_type = 'Mitigate'

    # base matrix
    @frequency = (0..4).to_a.reverse
    @like = Sra.get_likelihood
    risk_matrix_initializer
    # premium matrix
    load_special_matrix_form('sra', 'mitigate', @owner)

    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end


  def baseline
    @owner = Sra.find(params[:id])
    @risk_type = 'Baseline'

    # base matrix
    @frequency = (0..4).to_a.reverse
    @like = Sra.get_likelihood
    risk_matrix_initializer
    # premium matrix
    load_special_matrix_form('sra', 'baseline', @owner)
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end


  def edit
    load_options
    @has_status = true
    @fields = Sra.get_meta_fields('form')
    @sra = Sra.find(params[:id])
    @risk_group = @sra.matrix_connection.present? ? @sra.matrix_connection.matrix_group : ''
    @owner = @sra
    form_special_matrix(@sra, "sra", "severity_extra", "probability_extra")
  end


  def add_record
    @sra = Sra.find(params[:id])
    unwanted_ids = @sra.children.map(&:child_id)
    @records_hash = Record.where({status: ['Open', 'Linked']}).keep_if{|r| unwanted_ids.exclude?(r.id)}.map{|r| [r.id, r.description]}.to_h
    @instruction = "<p> Click anywhere on the <b>ROW</b> of the Reports you want to add to this SRA.</p>"

    render :partial => 'add_record'
  end


  def add_all_records
    @sra = Sra.find(params[:sra_id])
    records_added_ids = params[:records_selected].chomp(',').split(',')

    if records_added_ids.present?
      records_added_ids.each do |r|
        c = Child.create({child_type: 'Record', child_id: r.to_i, owner_type: 'Sra', owner_id: @sra.id})
        @sra.children << c
      end
      @sra.save
      message = "Report IDs #{records_added_ids.join(',')} added to this SRA"
    else
      message = "No reports added to this SRA"
    end
    flash[:notice] = message

    Transaction.build_for(
      @sra,
      'Reports Added',
      current_user.id,
      message
    )

    redirect_to sra_path(@sra)
  end


  def remove_record
    child = Child.where(owner_type: 'Sra', owner_id: params[:id].to_i, child_id: params[:record_id].to_i, child_type: 'Record').first rescue nil
    child.destroy if child.present?

    @sra = Sra.find(params[:id])
    @records = @sra.children.present? ? Record.where(id: @sra.children.map(&:child_id)) : []

    Transaction.build_for(
      @sra,
      'Report Removed',
      current_user.id,
      "Report ##{params[:record_id]} removed from this SRA"
    )

    render :json => {success: "Report removed from SRA", code: 200, deleted_id: params[:record_id].to_i}
  end


  def new_hazard
    @sra = Sra.find(params[:id])
    @hazard = Hazard.new
    form_special_matrix(@hazard, "sra[hazards_attributes][0]", "severity_extra", "probability_extra")
    load_options
    @fields = Hazard.get_meta_fields('form')
    respond_to do |format|
      format.js {render "/sras/new_hazard", layout: false}
    end
  end



  def close
    @sra = Sra.find(params[:id])
    render :partial => "close"
  end



  def load_options
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    risk_matrix_initializer
  end
  helper_method :load_options



  def destroy
    sra = Sra.find(params[:id])
    sra.destroy
    redirect_to sras_path(status: 'All'), flash: {danger: "SRA ##{params[:id]} deleted."}
  end




  def new_attachment
    @owner=Sra.find(params[:id])
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end

  def assign
    @owner = Sra.find(params[:id]).becomes(Sra)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = Sra.find(params[:id]).becomes(Sra)
    render partial: '/forms/workflow_forms/process', locals:{field: :closing_comment}
  end

  def approve
    @owner = Sra.find(params[:id]).becomes(Sra)
    pending_approval = @owner.status == 'Pending Approval'
    status = params[:commit].downcase == 'approve' ? ( pending_approval ? 'Completed' : 'Pending Approval') : 'Assigned'
    field = pending_approval ? :approver_comment : :reviewer_comment
    render :partial => '/forms/workflow_forms/process', locals: {status: status, field: field }
  end

  def override_status
    @owner = Sra.find(params[:id]).becomes(Sra)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def comment
    @owner = Sra.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end


  def get_agenda
    @sra = Sra.find(params[:id])
    @meeting = SrmMeeting.find(params[:meeting])
    @headers = SrmAgenda.get_headers
    @status = SrmAgenda.get_status
    @tof = {"Yes" => true,"No" => false}
    @accept_deline = {"Accepted" => true,"Declined" => false}
    render :partial => "agenda"
  end



  def carryover
    sra = Sra.find(params[:id])
    Transaction.build_for(
      sra.meeting,
      'Carry Over SRA',
      current_user.id,
      "SRA ##{sra.get_id} Carried Over"
    )
    Transaction.build_for(
      sra,
      'Carried Over',
      current_user.id,
      "SRA Carried Over from Meeting ##{sra.meeting.get_id}"
    )
    sra.meeting_id = nil
    sra.save
    render status: 200
  end



  # def mitigate
  #   @owner = Sra.find(params[:id])
  #   @risk_group = @owner.matrix_connection.matrix_group
  #   load_options
  #   mitigate_special_matrix("sra", "mitigated_severity", "mitigated_probability")

  #   @risk_type = 'Mitigate'
  #   render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  # end



  # def baseline
  #   @owner = Sra.find(params[:id])
  #   @risk_group = @owner.matrix_connection.matrix_group
  #   form_special_matrix(@sra, "sra", "severity_extra", "probability_extra")
  #   load_options

  #   @risk_type = 'Baseline'
  #   render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  # end



  def viewer_access
    @sra = Sra.find(params[:id])
    @sra.viewer_access=!@sra.viewer_access
    Transaction.build_for(
      @sra,
      "#{(@sra.viewer_access ? 'Enable' : 'Disable')} Viewer Access",
      current_user.id
    )
    @sra.save
    redirect_to sra_path(@sra)
  end



  def new_minutes
    @owner = Sra.find(params[:id])
    @meeting = Meeting.find(params[:meeting])
    render :partial => "shared/add_minutes"
  end



  def reopen
    @sra = Sra.find(params[:id])
    notify(@sra, notice: {
      users_id: @sra.responsible_user.id,
      content: "SRA ##{@sra.get_id} has been reopened and assigned."},
      mailer: true,
      subject: "SRA ##{@sra.get_id} Reopened and Assigned")
    reopen_report(@sra)
  end



  def new_section
    @owner = Sra.find(params[:owner_id])
    @templates = Template.find(:all)  # TODO
    respond_to do |format|
      format.js {render "/sections/new_section", layout: false}
    end
  end


  def add_section
    @owner = Sra.find(params[:owner_id])
    section = SraSection.create(params[:sections])
    section.owner = @owner
    new_section
  end


  def edit_section(owner_id=nil, section=nil)
    owner_id ||= params[:owner_id]
    section ||= params[:section]
    @owner = Sra.find(owner_id)
    @section = Section.find(section)
    respond_to do |format|
      format.js {render "/sections/edit_section", layout: false}
    end
  end

  def update_section
    @section = Section.find(params[:section_id])
    if params[:sections][:section_fields_attributes].present?
      params[:sections][:section_fields_attributes].each_value do |field|
        if field[:value].is_a?(Array)
          field[:value].delete("")
          field[:value] = field[:value].join(";")
        end
      end
    end
    @section.update_attributes(params[:sections])
    if params[:commit] == "Save"
      @section.status = "In Progress"
    elsif params[:commit] == "Submit"
      @section.status = "Completed"
    end
      @section.save
      edit_section(@section.owner.id, @section.id)
  end

private

  def filter_sras
    if params[:departments].present?
      @records = @records.select{|rec| rec.departments.present? &&
        rec.departments.any?{|x| params[:departments].include?(x)}
      }
    end

    if !current_user.has_access('sras','admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      cars = Sra.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Review', 'Pending Approval', 'Completed'],
        current_user.id)
      cars += Sra.where('approver_id = ? OR reviewer_id = ?',
        current_user.id, current_user.id)
      cars += Sra.where(viewer_access: true) if current_user.has_access('sras','viewer')
      cars += Sra.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
  end

end
