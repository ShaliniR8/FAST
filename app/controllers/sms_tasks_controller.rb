class SmsTasksController < ApplicationController

  def edit
    @record = SmsTask.find(params[:id])
    @owner = SmsTask.find(params[:id])

    if params[:commit].present?
      case params[:commit]
      when 'Assign'
        render partial: '/forms/workflow_forms/assign', locals: {field_name: 'res'}
      when 'Complete'
        status = @owner.final_approver.present? ? 'Pending Approval' : 'Completed'
        render :partial => '/forms/workflow_forms/process', locals: {status: status, field: :res_comment }
      when 'Reject'
        render partial: '/forms/workflow_forms/process', locals: {status: 'Assigned'}
      when 'Approve'
        render partial: '/forms/workflow_forms/process', locals: {status: 'Completed'}
      end
    else
      @fields = SmsTask.get_meta_fields('form')
      @title = "Task"
      render partial: '/forms/additional_forms/form'
    end
  end

  def update
    @record = SmsTask.find(params[:id])
    @record.update_attributes(params[:sms_task])

    case params[:commit]
    when 'Assign'
      notify(@record,
        notice: {
          users_id: @record.res,
          content: "Task ##{@record.id} has been assigned to you."},
        mailer: true,
        subject: 'Task Assigned')
    when 'Complete'
      if @record.final_approver
        update_status = 'Pending Approval'
        notify(@record,
          notice: {
            users_id: @record.app_id,
            content: "Task ##{@record.id} needs your Approval."},
          mailer: true,
          subject: 'Task Pending Approval')
      else
        @record.close_date = Time.now
        @record.save
      end
    when 'Reject'
      notify(@record,
          notice: {
            users_id: @record.res,
            content: "Task ##{@record.id} was Rejected by the Final Approver."},
          mailer: true,
          subject: 'Task Rejected')
    when 'Approve'
      @record.close_date = Time.now
      @record.save
      notify(@record,
          notice: {
            users_id: @record.res,
            content: "Task ##{@record.id} was Approved by the Final Approver."},
          mailer: true,
          subject: 'Task Approved')
    end


    if %w[FrameworkIm VpIm JobAid].include? @record.owner.class.name
      redirect_to @record.owner.becomes(Im), flash: {success: 'Task updated.'}
    else
      redirect_to @record.owner, flash: {success: 'Task updated.'}
    end
  end

  def destroy
    record = SmsTask.find(params[:id])
    owner = record.owner
    record.destroy

    if %w[FrameworkIm VpIm JobAid].include? owner.class.name
      redirect_to owner.becomes(Im), flash: {success: 'Task deleted.'}
    else
      redirect_to owner, flash: {success: 'Task deleted.'}
    end
  end

end
