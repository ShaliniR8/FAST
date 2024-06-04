# Current version of Ruby (2.1.1p76) and Rails (3.0.5) defines send s.t. saving nested attributes does not work
# This method is a "monkey patch" that can fix the issue (tested for Rails 3.0.x)
# Source: https://github.com/rails/rails/issues/11026
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


class CorrectiveActionsController < ApplicationController

  before_filter :set_table_name, :login_required
  before_filter :define_owner, only: [:request_extension, :schedule_verification]

  def define_owner
    @class = Object.const_get('CorrectiveAction')
    @owner = @class.find(params[:id])
  end

  def set_table_name
    @table_name = "corrective_actions"
  end


  def new
    @privileges = Privilege.find(:all)
    @corrective_action = CorrectiveAction.new
    if params[:report].present?
      @report = Report.find(params[:report])
    end
    if params[:record].present?
      @record = Record.find(params[:record])
    end
    if CONFIG.sr::GENERAL[:submission_corrective_action_root_cause].present? && params[:submission].present?
      @submission = Submission.find(params[:submission])
    end
    privileges_id = AccessControl.where(action: 'new', entry: 'corrective_actions').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    @fields = CorrectiveAction.get_meta_fields('form')
  end


  # def index
  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   handle_search if params[:advance_search].present?

  #   if !current_user.has_access('corrective_actions', 'admin', admin: true, strict: true)
  #     cars = CorrectiveAction.where('status in (?) and responsible_user_id = ?',
  #       ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
  #     cars += CorrectiveAction.where('approver_id = ?',  current_user.id)
  #     cars += CorrectiveAction.where('created_by_id = ?', current_user.id)
  #     @records = @records & cars
  #   end

  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def create
    @owner = CorrectiveAction.new(params[:corrective_action])
    @owner.status = "New"
    if @owner.save
      notify_on_object_creation(@owner)
      if @owner.submissions_id.present?
        redirect_to submission_path(Submission.find(@owner.submissions_id)), flash: {success: "Corrective Action created."}
      else
        redirect_to corrective_action_path(@owner), flash: {success: "Corrective Action created."}
      end
    else
      redirect_to new_corrective_action_path
    end
  end

  def show
    @has_status = true
    @fields = CorrectiveAction.get_meta_fields('show')
    @corrective_action = CorrectiveAction.find(params[:id])

    related_user_ids = []
    related_user_ids << @corrective_action.created_by_id
    if @corrective_action.responsible_user_id.present?
      related_user_ids << @corrective_action.responsible_user_id
    end
    if @corrective_action.approver_id.present?
      related_user_ids << @corrective_action.approver_id
    end

    has_access = current_user.has_access('corrective_actions', 'show', admin: CONFIG::GENERAL[:global_admin_default]) &&
                 (related_user_ids.include?(current_user.id) ||
                 current_user.has_access('corrective_actions', 'admin', admin: CONFIG::GENERAL[:global_admin_default]))
    redirect_to errors_path unless has_access

    @report = ''
    @record = ''
    if @corrective_action.report.present?
      @report = display_in_table(@corrective_action.report) ? @corrective_action.report : ''
    end
    if @corrective_action.record.present?
      @record = record_display(@corrective_action.record) ? @corrective_action.record : ''
    end
  end

  def override_status
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def assign
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    privileges_id = AccessControl.where(action: 'edit', entry: 'corrective_actions').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end


  def complete
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
    render :partial => '/forms/workflow_forms/process', locals: {status: status, field: :corrective_actions_comment}
  end

  def approve
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end


  def update
    transaction = true
    @owner = CorrectiveAction.find(params[:id])
    old_status = @owner.status
    @owner.update_attributes(params[:corrective_action])
    send_notification(@owner, params[:commit])
    transaction_content = params[:corrective_action][:corrective_actions_comment] rescue nil
    if transaction_content.nil?
      transaction_content = params[:corrective_action][:final_comment] rescue nil
    end
    if transaction_content.nil?
      if params[:corrective_action][:comments_attributes].present?
        params[:corrective_action][:comments_attributes].each do |key, val|
          transaction_content = val[:content] rescue nil
        end
      end
    end

    case params[:commit]
    when 'Assign'
      @owner.assigned_date = Time.now
    when 'Complete'
      if @owner.approver
      else
        @owner.close_date = Time.now
      end
    when 'Reject'
    when 'Approve'
      @owner.close_date = Time.now
    when 'Override Status'
      transaction_content = "Status overriden from #{old_status} to #{params[:corrective_action][:status]}"
      params[:corrective_action][:close_date] = params[:corrective_action][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    # @owner.update_attributes(params[:corrective_action])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content,
        nil,
        current_user,
        session[:platform]
      )
    end
    @owner.save
    redirect_to corrective_action_path(@owner)
  end




  def edit
    @has_status = true
    @corrective_action = CorrectiveAction.find(params[:id])
    @report = @corrective_action.report
    @record = @corrective_action.record
    if CONFIG.sr::GENERAL[:submission_corrective_action_root_cause].present?
      @submission = @corrective_action.submission
    end
    privileges_id = AccessControl.where(action: 'edit', entry: 'corrective_actions').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    @fields = CorrectiveAction.get_meta_fields('form')
  end





  def destroy
    @corrective_action = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    @corrective_action.destroy
    redirect_to corrective_actions_path(status: 'All'), flash: {danger: "Corrective Action ##{params[:id]} deleted."}
  end




  def get_term
    all_terms = CorrectiveAction.terms
    @item = all_terms[params[:term].to_sym]
    render :partial => "term"
  end




  def new_attachment
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    @attachment = Attachment.new
    render :partial => "shared/attachment_modal"
  end


  def comment
    @owner = CorrectiveAction.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end

  def request_extension
    @extension_request = @owner.extension_requests.new
    @extension_request.requester = current_user
    @extension_request.approver = @owner.approver
    @extension_request.request_date = Time.now
    render :partial => 'extension_requests/new'
  end

  def schedule_verification
      @verification = @owner.verifications.new
      @verification.validator = @owner.responsible_user
      render :partial => 'verifications/new'
  end

  def print
    @deidentified = params[:deidentified]
    @corrective_action = CorrectiveAction.find(params[:id])
    html = render_to_string(:template => "/pdfs/print_corrective_action.html.erb")
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
    filename = "Corrective_Action_##{@corrective_action.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end



end
