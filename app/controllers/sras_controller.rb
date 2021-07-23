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
    if params[:matrix_id].present?
      connection = SraMatrixConnection.create(
        :matrix_id => params[:matrix_id],
        :owner_id => @sra.id)
      connection.save
    end
    if @sra.save
      redirect_to sra_path(@sra), flash: {success: "SRA (SRM) created."}
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
        transaction_content = 'Rejected by the Quality Reviewer'
      else
        update_status = 'Assigned'
        notify(@owner,
          notice: {
            users_id: @owner.responsible_user.id,
            content: "SRA ##{@owner.id} was Rejected by the Final Approver."},
          mailer: true,
          subject: 'SRA Rejected') if @owner.responsible_user
        transaction_content = 'Rejected by the Final Approver'
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
    @root_cause_headers = HazardRootCause.get_headers
    @description_headers = Cause.get_meta_fields('show')
    @agenda_headers = SrmAgenda.get_headers
    @sra = Sra.find(params[:id])
    @risk_group = @sra.matrix_connection.present? ? @sra.matrix_connection.matrix_group : ''
    @owner = @sra
    load_options
    load_special_matrix(@sra)
    @fields = Sra.get_meta_fields('show')
  end



  def edit
    load_options
    @fields = Sra.get_meta_fields('form')
    @sra = Sra.find(params[:id])
    @risk_group = @sra.matrix_connection.present? ? @sra.matrix_connection.matrix_group : ''
    @owner = @sra
    form_special_matrix(@sra, "sra", "severity_extra", "probability_extra")
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
    sra.status = "New"
    sra.save
    render status: 200
  end



  def mitigate
    @owner = Sra.find(params[:id])
    @risk_group = @owner.matrix_connection.matrix_group
    load_options
    mitigate_special_matrix("sra", "mitigated_severity", "mitigated_probability")

    @risk_type = 'Mitigate'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end



  def baseline
    @owner = Sra.find(params[:id])
    @risk_group = @owner.matrix_connection.matrix_group
    form_special_matrix(@sra, "sra", "severity_extra", "probability_extra")
    load_options

    @risk_type = 'Baseline'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end



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
