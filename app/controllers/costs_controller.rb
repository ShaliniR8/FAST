class CostsController < ApplicationController

  def edit
    @record = Cost.find(params[:id])
    @fields = Cost.get_meta_fields('form')
    @title = "Task"
    render partial: '/forms/additional_forms/form'
  end

  def update
    @record = Cost.find(params[:id])
    @record.update_attributes(params[:cost])
    redirect_to @record.owner, flash: {success: 'Cost updated.'}
  end

  def destroy
    record = Cost.find(params[:id])
    owner = record.owner
    record.destroy
    redirect_to owner, flash: {success: 'Cost deleted.'}
  end

end
