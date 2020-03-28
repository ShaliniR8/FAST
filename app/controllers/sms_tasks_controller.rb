class SmsTasksController < ApplicationController

  def edit
    @record = SmsTask.find(params[:id])
    @fields = SmsTask.get_meta_fields('form')
    @title = "Task"
    render partial: '/forms/additional_forms/form'
  end

  def update
    @record = SmsTask.find(params[:id])
    @record.update_attributes(params[:sms_task])
    redirect_to @record.owner, flash: {success: 'Task updated.'}
  end

  def destroy
    record = SmsTask.find(params[:id])
    owner = record.owner
    record.destroy
    redirect_to owner, flash: {success: 'Task deleted.'}
  end

end
