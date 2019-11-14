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

  # Handles permissions and ability to execute button actions
  def interpret
    begin
      unless CONFIG.check_action(current_user, params[:act].to_sym, @owner)
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
      status = params[:commit] == 'approve' ? 'Completed' : 'Assigned'
      render partial: '/forms/workflow_forms/process', locals: {status: status}

    when :assign # was assign route
      render partial: '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}

    when :attach_in_message
      redirect_to new_message_path(owner_id: @owner.id, owner_class: @owner.class)

    when :comment
      @comment = @owner.comments.new
      render partial: '/forms/viewer_comment'

    when :complete # was complete route
      status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
      render partial: '/forms/workflow_forms/process', locals: {status: status}

    when :contact
      @contact = Contact.new
      render :partial => 'forms/contact_form'

    when :cost
      @cost = @owner.costs.new
      render :partial => 'forms/new_cost'

    # :delete handled safely by link_to in render_buttons

    # :edit handled safely by link_to in render_buttons

    #TODO- properly make the print functionality class ambiguous (applies for pdf and deid_pdf)
    # when :print
    #   # Add to filter_before for defining @owner and class
    #   @deidentified = params[:deidentified]
    #   html = render_to_string(:template=>"/audits/print.html.erb")
    #   pdf = PDFKit.new(html)
    #   pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    #   pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    #   filename = "Audit_#{@audit.get_id}" + (@deidentified ? '(de-identified)' : '')
    #   send_data pdf.to_pdf, :filename => "#{filename}.pdf"

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

    else
      redirect_to eval("#{@class.name.underscore}_path(@owner)"),
        flash: {danger: 'Unknown process- action aborted.'}
    end
  end



  def destroy #KEEP
    @owner.destroy
    redirect_to eval("#{@class.name.underscore}s_path"), flash: {danger: "#{@class.name.titleize} ##{@owner.id} deleted."}
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
