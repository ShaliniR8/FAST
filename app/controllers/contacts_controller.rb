class ContactsController < ApplicationController

  def edit
    @record = Contact.find(params[:id])
    @fields = Contact.get_meta_fields('form')
    @title = "Task"
    render partial: '/forms/additional_forms/form'
  end

  def update
    @record = Contact.find(params[:id])
    @record.update_attributes(params[:contact])
    redirect_to @record.owner, flash: {success: 'Contact updated.'}
  end

  def destroy
    record = Contact.find(params[:id])
    owner = record.owner
    record.destroy
    redirect_to owner, flash: {success: 'Contact deleted.'}
  end

end
