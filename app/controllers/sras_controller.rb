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

  before_filter :login_required
  before_filter :load_options
  before_filter :define_owner, only: [:show, :interpret]

  def define_owner
    @class = Object.const_get('Sra')
    @owner = Sra.find(params[:id])
  end

  def index
    @title = "SRAs"
    @table = Object.const_get("Sra")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    if params[:departments].present?
      @records = @records.select{|rec| rec.departments.present? &&
        rec.departments.any?{|x| params[:departments].include?(x)}
      }
    end

    if !current_user.has_access('sras','admin', admin: true, strict: true)
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
    sra = Sra.create(params[:sra])
    sra.status = 'New'
    if params[:matrix_id].present?
      connection = SraMatrixConnection.create(
        :matrix_id => params[:matrix_id],
        :owner_id => sra.id)
      connection.save
    end
    if sra.save
      redirect_to sra_path(sra), flash: {success: "SRA (SRM) created."}
    end
  end



  def update
    transaction = true
    @owner = Sra.find(params[:id]).becomes(Sra)
    sra_meeting = @owner.meeting
    meeting_redirect = false
    case params[:commit]
    when 'Assign'
      notify(@owner.responsible_user,
        "SRA ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'SRA Assigned')
    when 'Complete'
      if @owner.reviewer
        update_status = 'Pending Review'
        notify(@owner.reviewer,
          "SRA ##{@owner.id} needs your Review." + g_link(@owner),
          true, 'SRA Pending Review')
      elsif @owner.approver
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "SRA ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'SRA Pending Approval')
      else
        @owner.date_complete = Time.now
        @owner.close_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      if @owner.status == 'Pending Review'
        update_status = 'Assigned'
        notify(@owner.responsible_user,
          "SRA ##{@owner.id} was Rejected by the Quality Reviewer." + g_link(@owner),
          true, 'SRA Rejected')
        transaction_content = 'Rejected by the Quality Reviewer'
      else
        update_status = 'Assigned'
        notify(@owner.responsible_user,
          "SRA ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
          true, 'SRA Rejected')
        transaction_content = 'Rejected by the Final Approver'
      end
    when 'Approve'
      if !@owner.approver #Approved by reviewer with absent approver case
        update_status = 'Completed'
        notify(@owner.responsible_user,
          "SRA ##{@owner.id} was Approved by the Quality Reviewer." + g_link(@owner),
          true, 'SRA Approved')
        transaction_content = 'Approved by the Quality Reviewer'
      elsif @owner.status == 'Pending Review' #We update status after the switch case; this is the old status we compare
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "SRA ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'SRA Pending Approval')
        transaction_content = 'Approved by the Quality Reviewer'
      else
        @owner.date_complete = Time.now
        @owner.close_date = Time.now
        notify(@owner.responsible_user,
          "SRA ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
          true, 'SRA Approved')
        transaction_content = 'Approved by the Final Approver'
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
    redirect_to sras_path, flash: {danger: "SRA ##{params[:id]} deleted."}
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

  def print
    @deidentified = params[:deidentified]
    @sra = Sra.find(params[:id])
    html = render_to_string(:template => "/sras/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "SRA_##{@sra.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
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
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial=>"shared/mitigate"
    else
      render :partial => "/risk_matrix_groups/form_mitigated"
    end
  end



  def baseline
    @owner = Sra.find(params[:id])
    @risk_group = @owner.matrix_connection.matrix_group
    form_special_matrix(@sra, "sra", "severity_extra", "probability_extra")
    load_options
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial=>"shared/baseline"
    else
      render :partial => "/risk_matrix_groups/form_baseline"
    end
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
    notify(
      @sra.responsible_user,
      "SRA ##{@sra.get_id} has been reopened and assigned." +
        g_link(@sra),
      true,
      "SRA ##{@sra.get_id} Reopened and Assigned")
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


end
