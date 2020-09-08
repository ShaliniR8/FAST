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


    if @record.owner.class.name == 'FrameworkIm'
      redirect_to @record.owner.becomes(Im), flash: {success: 'Task updated.'}
    else
      redirect_to @record.owner, flash: {success: 'Task updated.'}
    end
  end

  def destroy
    record = SmsTask.find(params[:id])
    owner = record.owner
    record.destroy

    if @record.owner.class.name == 'FrameworkIm'
      redirect_to owner.becomes(Im), flash: {success: 'Task deleted.'}
    else
      redirect_to owner, flash: {success: 'Task deleted.'}
    end
  end

end
