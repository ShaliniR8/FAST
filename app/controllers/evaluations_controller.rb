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

class EvaluationsController < ApplicationController
  before_filter :login_required
  before_filter(only: [:show]) { check_group('evaluation') }


  def new
    @evaluation = Evaluation.new
    load_options
    @fields = Evaluation.get_meta_fields('form')
  end



  def edit
    @evaluation = Evaluation.find(params[:id])
    load_options
    @fields = Evaluation.get_meta_fields('form')
  end



  def destroy
    Evaluation.find(params[:id]).destroy
    redirect_to evaluations_path, flash: {danger: "Evaluation ##{params[:id]} deleted."}
  end



  def viewer_access
    evaluation = Evaluation.find(params[:id])
    evaluation.viewer_access = !evaluation.viewer_access
    if evaluation.viewer_access
      content = "Viewer Access Enabled"
    else
      content = "Viewer Access Disabled"
    end
    EvaluationTransaction.create(
      :users_id => current_user.id,
      :action => "Viewer Access",
      :owner_id => evaluation.id,
      :content => content,
      :stamp => Time.now)
    evaluation.save
    redirect_to evaluation_path(evaluation)
  end


  def print
    @deidentified = params[:deidentified]
    @evaluation = Evaluation.find(params[:id])
    @requirement_headers = EvaluationRequirement.get_meta_fields('show')
    html = render_to_string(:template=>"/evaluations/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Evaluation_##{@evaluation.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end



  def update
    @owner = Evaluation.find(params[:id]).becomes(Evaluation)
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Evaluation ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Evaluation Assigned')
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "Evaluation ##{@owner.id} needs your Approval" + g_link(@owner),
          true, 'Evaluation Pending Approval')
      else
        @owner.complete_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Evaluation ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Evaluation Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Evaluation ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Evaluation Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:evaluation][:status]}"
    end
    @owner.update_attributes(params[:evaluation])
    @owner.status = update_status || @owner.status
    EvaluationTransaction.create(
      users_id:   current_user.id,
      action:     params[:commit],
      owner_id:   @owner.id,
      content:    transaction_content,
      stamp:      Time.now
    )
    @owner.save
    redirect_to evaluation_path(@owner)
  end



  def new_task
    @audit = Evaluation.find(params[:id])
    load_options
    @task = EvaluationTask.new
    render :partial => 'audits/task'
  end



  def new_contact
    @audit = Evaluation.find(params[:id])
    @contact = EvaluationContact.new
    render :partial => 'audits/contact'
  end



  def new_requirement
    @audit = Evaluation.find(params[:id])
    @fields = EvaluationRequirement.get_meta_fields('form')
    @requirement = EvaluationRequirement.new
    load_options
    render :partial => 'audits/requirement'
  end



  def new_finding
    @audit = Evaluation.find(params[:id])
    @finding = EvaluationFinding.new
    @classifications = Finding.get_classifications
    form_special_matrix(@finding, "evaluation[findings_attributes][0]", "severity_extra", "probability_extra")
    load_options
    @fields = Finding.get_meta_fields('form')
    render :partial => "audits/finding"
  end



  def create
    evaluation = Evaluation.new(params[:evaluation])
    if evaluation.save
      redirect_to evaluation_path(evaluation), flash: {success: "Evaluation created."}
    end
  end



  def index
    @table = Object.const_get("Evaluation")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    @records = @records.keep_if{|x| x[:template].nil? || x[:template] == 0}
    if !current_user.admin? && !current_user.has_access('evaluations','admin')
      cars = Evaluation.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Evaluation.where('approver_id = ?',  current_user.id)
      if current_user.has_access('evaluations','viewer')
        Evaluation.where('viewer_access = true').each do |viewable|
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
    @evaluation = Evaluation.find(params[:id])
    load_options
    @fields = Evaluation.get_meta_fields('show')
    if !@evaluation.viewer_access && !current_user.has_access('evaluations','viewer')
      redirect_to errors_path
      return
    end
    @checklist_headers = EvaluationRequirement.get_meta_fields('show')
  end



  def load_options
    @privileges = Privilege.find(:all)
    @privileges.keep_if{|p| keep_privileges(p, 'evaluations')}.sort_by!{|a| a.name}
    @plan = {"Yes" => true, "No" => false}
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    @cause_headers = FindingCause.get_headers
    risk_matrix_initializer
  end
  helper_method :load_options


  def upload_checklist
    evaluation = Evaluation.find(params[:id])
    if !params[:append].present?
      evaluation.clear_checklist
    end
    if params[:checklist].present?
      upload = File.open(params[:checklist].tempfile)
      CSV.foreach(upload,{
        :headers => :true,
        :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }
        }) do |row|
        EvaluationItem.create(row.to_hash.merge({:owner_id => evaluation.id}))
      end
    end
    EvaluationTransaction.create(
      :users_id => current_user.id,
      :action => "Upload Checklist",
      :owner_id => params[:id],
      :stamp => Time.now)
    redirect_to evaluation_path(evaluation)
  end



  def new_checklist
    @evaluation = Evaluation.find(params[:id])
    @path = upload_checklist_evaluation_path(@evaluation)
    render :partial => 'checklist'
  end



  def update_checklist
    @audit = Evaluation.find(params[:id])
    @checklist_headers = EvaluationItem.get_meta_fields
    render :partial => "audits/update_checklist"
  end

  def assign
    @owner = Evaluation.find(params[:id]).becomes(Evaluation)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = Evaluation.find(params[:id]).becomes(Evaluation)
    render :partial => "/forms/workflow_forms/process"
  end

  def approve
    @owner = Evaluation.find(params[:id]).becomes(Evaluation)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def override_status
    @owner = Evaluation.find(params[:id]).becomes(Evaluation)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def new_attachment
      @owner = Evaluation.find(params[:id])
      @attachment=EvaluationAttachment.new
      render :partial => "shared/attachment_modal"
  end



  def download_checklist
    @evaluation = Evaluation.find(params[:id])
  end



  def reopen
    @evaluation = Evaluation.find(params[:id])
    reopen_report(@evaluation)
  end



end

