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

class ChecklistsController < ApplicationController
  require 'csv'

  before_filter :login_required

  def new
    @owner = Object.const_get("#{params[:owner_class]}").find(params[:owner_id])
    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h
    render :partial => 'form'
  end

  def create
    @owner = Object.const_get("#{params[:owner_class]}").find(params[:checklist][:owner_id])
    @table = Object.const_get("#{params[:owner_class]}Checklist")
    @record = @table.create(params[:checklist])
    if params[:checklist_upload].present?
      upload = File.open(params[:checklist_upload].tempfile)
      create_records_from_upload(upload, @record)
    end
    redirect_to @owner
  end


  def edit
    @owner = Checklist.find(params[:id]).becomes(Checklist)
    render :partial => 'edit'
  end


  def update
    @owner = Checklist.find(params[:id])
    @owner.update_attributes(params[:checklist])
    redirect_to @owner.owner
  end


  def show
    @table = Object.const_get("#{params[:owner_class]}Checklist")
    render :partial => 'show'
  end


  def start
    @owner = Checklist.find(params[:id]).becomes(Checklist)
    render :partial => 'edit'
  end


  def retract_form
    @owner = Object.const_get("#{params[:owner_class]}").find(params[:owner_id])
    @table = Object.const_get("#{params[:owner_class]}Checklist")
    @record = @table.new
    @checklist_header = ChecklistHeader.find(params[:checklist_header])
    render :partial => 'extra_form'
  end


  def destroy
    checklist = Checklist.find(params[:id])
    owner = checklist.owner
    checklist.destroy
    redirect_to owner
  end


  def export
    @record = Checklist.find(params[:id])
  end


  private

  def create_records_from_upload(upload, owner)
    checklist_header_items = owner.checklist_header.checklist_header_items
    begin
      CSV.foreach(upload, :headers => true) do |row|
        checklist_row = ChecklistRow.create({:checklist_id => owner.id, :created_by_id => current_user.id})
        row.each_with_index do |cell, index|
          cell = ChecklistCell.create({
            :checklist_row_id => checklist_row.id,
            :value => cell[1],
            :checklist_header_item_id => checklist_header_items[index]})
        end
      end
    rescue Exception => e
    end
  end


end
