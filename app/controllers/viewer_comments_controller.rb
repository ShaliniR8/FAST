class ViewerCommentsController < ApplicationController

  def edit
    @record = ViewerComment.find(params[:id])
    @fields = ViewerComment.get_meta_fields('form')
    @title = "Task"
    render partial: '/forms/additional_forms/form'
  end

  def update
    @record = ViewerComment.find(params[:id])
    @record.update_attributes(params[:viewer_comment])
    redirect_to @record.owner, flash: {success: 'Comment updated.'}
  end

  def destroy
    record = ViewerComment.find(params[:id])
    owner = record.owner
    record.destroy
    redirect_to owner, flash: {success: 'Comment deleted.'}
  end

end
