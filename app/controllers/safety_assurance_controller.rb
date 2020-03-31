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
    if !current_user.has_access(@owner.class.name.downcase.underscore, 'admin', admin: true, strict: true)
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
