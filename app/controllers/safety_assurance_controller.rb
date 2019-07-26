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

  def approve
    if !@owner.can_approve? current_user
      redirect_to errors_path
      return false
    end
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def assign
    if !@owner.can_assign?(current_user)
      redirect_to errors_path
      return false
    end
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def comment
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end

  def complete
    if !@owner.can_complete?(current_user)
      redirect_to errors_path
      return false
    end
    render :partial => '/forms/workflow_forms/process'
  end

  def destroy
    @owner.destroy
    redirect_to eval("#{@class.name.underscore}s_path"), flash: {danger: "#{@class.name.titleize} ##{@owner.id} deleted."}
  end

  def new_attachment
    @attachment = Attachment.new
    render :partial => "shared/attachment_modal"
  end

  def new_contact
    @contact = Contact.new
    render :partial => 'forms/contact_form'
  end

  def new_cost
    @cost = @owner.costs.new
    render :partial => 'forms/new_cost'
  end

  def new_signature
    @signature = Signature.new
    render partial: 'forms/signatures/sign'
  end

  def new_task
    load_options
    @task = @owner.tasks.new
    render :partial => 'forms/task'
  end

  def override_status
    if !current_user.admin?
      redirect_to errors_path
      return false
    end
    render :partial => '/forms/workflow_forms/override_status'
  end

  def reopen
    redirect_to errors_path if !@owner.can_reopen? current_user
    reopen_report(@owner)
  end

  def viewer_access
    @owner.viewer_access = !@owner.viewer_access
    if @owner.viewer_access
      content = "Viewer Access Enabled"
    else
      content = "Viewer Access Disabled"
    end
    Transaction.build_for(
      @owner,
      'Viewer Access',
      current_user.id, content
    )
    @owner.save
    redirect_to eval("#{@class.name.underscore}_path(@owner)")
  end

end
