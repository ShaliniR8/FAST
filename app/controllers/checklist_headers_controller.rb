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

class ChecklistHeadersController < ApplicationController

  require 'csv'

  before_filter :login_required, :set_table

  def set_table
    @table = Object.const_get("ChecklistHeader")
  end


  def index
    @records = @table.all
    @headers = @table.get_meta_fields('index')
  end

  def show
    @record = @table.find(params[:id])
    @fields = @table.get_meta_fields('show')
  end

  def new
    @record = @table.new
    @fields = @table.get_meta_fields('form')
  end

  def create
    @record = @table.create(params[:checklist_header])
    redirect_to checklist_header_path(@record)
  end

  def edit
    @record = @table.find(params[:id])
    @fields = @table.get_meta_fields('form')
  end

  def update
    @record = @table.find(params[:id])
    @record.update_attributes(params[:checklist_header])
    redirect_to checklist_header_path(@record)
  end

  def destroy
    @table.find(params[:id]).destroy
    redirect_to checklist_headers_path
  end

  def export
    @record = @table.find(params[:id])
  end

  def clone
    @record = ChecklistHeader.find(params[:id]).duplicate
    @record.status = 'New'
    @record.save
    redirect_to checklist_header_path(@record)
  end


end
