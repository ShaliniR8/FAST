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

class InspectionsController < ApplicationController
  before_filter :login_required
  before_filter(only: [:show]) { check_group('inspection') }


  def new
    @inspection = Inspection.new
    load_options
    @fields = Inspection.get_meta_fields('form')
  end

  def comment
    @owner = Inspection.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end

  def edit
    @inspection = Inspection.find(params[:id])
    load_options
    @fields = Inspection.get_meta_fields('form')
  end



  def destroy
    Inspection.find(params[:id]).destroy
    redirect_to inspections_path, flash: {danger: "Inspection ##{params[:id]} deleted."}
  end



  def viewer_access
    inspection = Inspection.find(params[:id])
    inspection.viewer_access = !inspection.viewer_access
    if inspection.viewer_access
      content = "Viewer Access Enabled"
    else
      content = "Viewer Access Disabled"
    end
    Transaction.build_for(
      inspection,
      'Viewer Access',
      current_user.id,
      content
    )
    inspection.save
    redirect_to inspection_path(inspection)
  end


  def print
    @deidentified = params[:deidentified]
    @inspection = Inspection.find(params[:id])
    @requirement_headers = InspectionRequirement.get_meta_fields('show')
    html = render_to_string(:template=>"/inspections/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Inspection_##{@inspection.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def update
    @owner = Inspection.find(params[:id]).becomes(Inspection)

    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Inspection ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Inspection Assigned')
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "Inspection ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Inspection Pending Approval')
      else
        @owner.complete_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Inspection ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Inspection Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Inspection ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Inspection Approved')
    when 'Override Status'
      transaction_content = "Status overridden from #{@owner.status} to #{params[:inspection][:status]}"
    end
    @owner.update_attributes(params[:inspection])
    @owner.status = update_status || @owner.status
    Transaction.build_for(
      @owner,
      params[:commit],
      current_user.id,
      transaction_content
    )
    @owner.save
    redirect_to inspection_path(@owner)
  end



  def new_task
    @owner = Inspection.find(params[:id])
    load_options
    @task = @owner.tasks.new
    render :partial => 'forms/task'
  end



  def new_contact
    @owner = Inspection.find(params[:id])
    @contact = Contact.new
    render :partial => 'forms/contact_form'
  end



  def new_requirement
    @audit = Inspection.find(params[:id])
    @requirement = InspectionRequirement.new
    @fields = InspectionRequirement.get_meta_fields('form')
    load_options
    render :partial => 'audits/requirement'
  end


  def create
    inspection = Inspection.new(params[:inspection])
    if inspection.save
      redirect_to inspection_path(inspection),  flash: {success: "Inspection created."}
    end
  end



  def index
    @table = Object.const_get("Inspection")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    @records = @records.where('template = 0 OR template IS NULL')
    if !current_user.admin? && !current_user.has_access('inspections','admin')
      cars = Inspection.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Inspection.where('approver_id = ?',  current_user.id)
      if current_user.has_access('inspections','viewer')
        Inspection.where('viewer_access = true').each do |viewable|
          if viewable.privileges.empty?
            cars += [viewable]
          else
            viewable.privileges.each do |privilege|
              current_user.privileges.include? privilege
              cars += [viewable]
            end
          end
        end
      end
      @records = @records & cars
    end
  end



  def show
    @inspection = Inspection.find(params[:id])
    load_options
    @fields = Inspection.get_meta_fields('show')
    @checklist_headers = InspectionRequirement.get_meta_fields('show')
  end



  def load_options
    @privileges = Privilege.find(:all)
    @privileges.keep_if{|p| keep_privileges(p, 'inspections')}.sort_by!{|a| a.name}
      @users = User.find(:all)
      @users.keep_if{|u| !u.disable && u.has_access('inspections', 'edit')}
      @headers = User.get_headers
      # @departments = Inspection.get_departments
      @plan = {"Yes" => true, "No" => false}
      @supplier = ['External','Internal','Supplier']
      @types = Inspection.select(:inspection_type).uniq
      @station_codes = Inspection.select(:station_code).uniq
      @vendors = Inspection.select(:vendor).uniq
      @frequency = (0..4).to_a.reverse
      @like = Finding.get_likelihood
      @cause_headers = FindingCause.get_headers
      risk_matrix_initializer
  end
  helper_method :load_options



  def upload_checklist
    inspection = Inspection.find(params[:id])
    if !params[:append].present?
      inspection.clear_checklist
    end
    if params[:checklist].present?
      upload = File.open(params[:checklist].tempfile)
      CSV.foreach(upload,{
        :headers => :true,
        :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }
        }) do |row|
        InspectionItem.create(row.to_hash.merge({:owner_id=>inspection.id}))
      end
    end
    Transaction.build_for(
      inspection,
      'Upload Checklist',
      current_user.id
    )
    redirect_to inspection_path(inspection)
  end



  def new_checklist
    @inspection = Inspection.find(params[:id])
      @path = upload_checklist_inspection_path(@inspection)
    render :partial => 'checklist'
  end



  def update_checklist
    @audit = Inspection.find(params[:id])
    @checklist_headers = InspectionItem.get_headers
    render :partial => "audits/update_checklist"
  end

  def assign
    @owner = Inspection.find(params[:id]).becomes(Inspection)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = Inspection.find(params[:id]).becomes(Inspection)
    render :partial => '/forms/workflow_forms/process'
  end

  def approve
    @owner = Inspection.find(params[:id]).becomes(Inspection)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def override_status
    @owner = Inspection.find(params[:id]).becomes(Inspection)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def new_attachment
      @owner = Inspection.find(params[:id])
      @attachment = Attachment.new
      render :partial => "shared/attachment_modal"
  end



  def download_checklist
    @inspection = Inspection.find(params[:id])
  end



  def reopen
    @inspection = Inspection.find(params[:id])
    reopen_report(@inspection)
  end


end
