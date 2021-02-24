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

class SafetyAssuranceController < ApplicationController

  def update
    convert_from_risk_value_to_risk_index

    object_name = self.class.name.gsub('Controller', '').underscore.singularize

    transaction = true

    if params[object_name][:checklists_attributes].present?
      params[object_name][:checklists_attributes].each do |key, checklist|

        checklist[:checklist_rows_attributes].each do |row_key, row_attributes|

          if row_attributes[:attachments_attributes].present?

            row_attributes[:attachments_attributes].each do |att_key, attachment|

              # File is a base64 string
              if attachment[:name].present? && attachment[:name].is_a?(Hash)
                file_params = attachment[:name]

                temp_file = Tempfile.new('file_upload')
                temp_file.binmode
                temp_file.write(Base64.decode64(file_params[:base64]))
                temp_file.rewind()

                file_name = file_params[:fileName]
                mime_type = Mime::Type.lookup_by_extension(File.extname(file_name)[1..-1]).to_s

                uploaded_file = ActionDispatch::Http::UploadedFile.new(
                  :tempfile => temp_file,
                  :filename => file_name,
                  :type     => mime_type)

                # Replace attachment parameter with the created file
                params[object_name][:checklists_attributes][key][:checklist_rows_attributes][row_key][:attachments_attributes][att_key][:name] = uploaded_file
              end
            end
          end
        end
      end
    end


    current_status = @owner.status
    @owner.update_attributes(params[object_name.to_sym])
    send_notification(@owner, params[:commit])
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
    when 'Complete'
      if @owner.approver
        transaction_content ='Pending Approval'
      else
        @owner.close_date = Time.now
      end
    when 'Reject'
    when 'Approve'
      @owner.close_date = Time.now
    when 'Override Status'
      transaction_content = "Status overridden from #{current_status} to #{@owner.status}"
      @owner.close_date = params[object_name.to_sym][:status] == 'Completed' ? Time.now : nil
    when 'Add Cost', 'Add Contact', 'Add Attachment'
      transaction = false
    end

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
    respond_to do |format|
      format.html { redirect_to eval "#{object_name}_path(@owner)" }
      format.json { update_as_json }
    end
  end

  #############################
  ####    SHARED FORMS     ####
  #############################

  # Interpret is found in the ApplicationController

  def destroy #KEEP
    @owner.destroy
    redirect_to eval("#{@class.name.underscore}s_path(status: 'All')"), flash: {danger: "#{@class.name.titleize} ##{@owner.id} deleted."}
  end

  def new_attachment #KEEP
    @attachment = Attachment.new
    render :partial => 'shared/attachment_modal'
  end

  def override_status
    if !current_user.has_access(@owner.class.name.downcase.underscore, 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      redirect_to errors_path
      return false
    end
    render :partial => '/forms/workflow_forms/override_status'
  end

  def viewer_access
    @owner.viewer_access = !@owner.viewer_access
    if @owner.viewer_access
      content = 'Viewer Access Enabled'
    else
      content = 'Viewer Access Disabled'
    end
    Transaction.build_for(
      @owner,
      'Viewer Access',
      current_user.id, content
    )
    @owner.save
    redirect_to eval("#{@class.name.underscore}_path(@owner)")
  end

  #############################
  ##### Deprecated Routes #####
  #############################

  def approve # DEPRECATED
    unless CONFIG.check_action(current_user, :approve_reject, @owner)
      redirect_to eval("#{@class.name.underscore}_path(@owner)"),
        flash: {danger: "Unable to approve #{@owner.class.titleize}."}
      return false
    end
    status = params[:commit] == 'approve' ? 'Completed' : 'Assigned'
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def assign # DEPRECATED
    unless CONFIG.check_action(current_user, :assign, @owner)
      redirect_to eval("#{@class.name.underscore}_path(@owner)"),
        flash: {danger: "Unable to assign #{@owner.class.titleize}."}
      return false
    end
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def comment # DEPRECATED
    @comment = @owner.comments.new
    render :partial => 'forms/viewer_comment'
  end

  def complete # DEPRECATED
    if !@owner.can_complete?(current_user)
      redirect_to errors_path
      return false
    end
    status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def new_contact # DEPRECATED
    @contact = Contact.new
    render :partial => 'forms/contact_form'
  end

  def new_cost # DEPRECATED
    @cost = @owner.costs.new
    render :partial => 'forms/new_cost'
  end

  def new_signature # DEPRECATED
    @signature = Signature.new
    render partial: 'forms/signatures/sign'
  end

  def new_task # DEPRECATED
    load_options
    @task = @owner.tasks.new
    render :partial => 'forms/task'
  end

  def reopen # DEPRECATED
    redirect_to errors_path if !@owner.can_reopen? current_user
    reopen_report(@owner)
  end

end
