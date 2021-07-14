class ViewerCommentsController < ApplicationController

  def edit
    @record = ViewerComment.find(params[:id])
    @fields = ViewerComment.get_meta_fields('form')
    owner_name_sym = @record.owner.class.name.underscore.pluralize.to_sym
    @title = "#{CONFIG::LABELS[owner_name_sym] || 'Comment'}s"
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
