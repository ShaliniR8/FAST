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

class ChecklistTemplatesController < ApplicationController

  require 'csv'

  before_filter :login_required


  def index
    @table_name = "checklist_templates"
    @records = ChecklistTemplate.where(archive: 0)
    @headers = ChecklistTemplate.get_meta_fields('index')
    @title = "Checklist Templates"
  end

  def show
    @checklist_template = ChecklistTemplate.find(params[:id])
    @fields = ChecklistTemplate.get_meta_fields('show')
  end

  def new
    @title = "New Checklist Template"
    @checklist_template = ChecklistTemplate.new
    @fields = ChecklistTemplate.get_meta_fields('form')
  end

  def create
    @checklist_template = ChecklistTemplate.create(params[:checklist_template])
    if params[:checklist_upload].present?
      upload = File.open(params[:checklist_upload].tempfile)
      create_questions_from_upload(upload, @checklist_template)
    end
    redirect_to checklist_template_path(@checklist_template), :flash => {:success => "Template created."}
  end

  def edit
    @title = "Edit Checklist Template"
    @checklist_template = ChecklistTemplate.find(params[:id])
    @fields = ChecklistTemplate.get_meta_fields('form')
  end

  def update
    @checklist_template = ChecklistTemplate.find(params[:id])
    @checklist_template.update_attributes(params[:checklist_template])
    if params[:checklist_upload].present?
      upload = File.open(params[:checklist_upload].tempfile)
      create_questions_from_upload(upload, @checklist_template)
    end
    redirect_to checklist_template_path(@checklist_template), :flash => {:success => "Template saved."}
  end

  def destroy
    ChecklistTemplate.find(params[:id]).destroy
    redirect_to checklist_templates_path, flash: {danger: "Template deleted."}
  end

  def download_records
    @owner = Object.const_get(params[:owner_class]).find(params[:owner_id])
  end

  def select_checklist
    @owner_class = params[:owner_class]
    @owner_id = params[:owner_id]
    @checklist_templates = ChecklistTemplate.where(archive: 0)
    render :partial => "/checklist_templates/select_checklist"
  end

  def create_checklist_record
    @owner = Object.const_get(params[:owner_class]).find(params[:owner_id])
    if params[:checklist_template].present?
      @checklist_template = ChecklistTemplate.find(params[:checklist_template])
      @checklist_template.create_checklist_records(params[:owner_class], params[:owner_id])
    end
    if params[:checklist_upload].present?
      upload = File.open(params[:checklist_upload].tempfile)
      create_records_from_upload(upload, @owner)
    end
    redirect_to @owner
  end


  private

  def create_questions_from_upload(upload, checklist_template)
    begin
      CSV.foreach(upload, {
        :headers => :true,
        :header_converters => lambda { |h| h.downcase.gsub(' ', '_')}
      }) do |row|
        puts row.inspect
        ChecklistQuestion.create(row.to_hash.merge({:owner_id => checklist_template.id}))
      end
    rescue Exception => e
    end
  end

  def create_records_from_upload(upload, owner)
    class_name = owner.class.name
    @table = Object.const_get("#{class_name}ChecklistRecord")
    begin
      CSV.foreach(upload, {
        :headers => :true,
        :header_converters => lambda { |h| h.downcase.gsub(' ', '_')}
      }) do |row|
        @table.create(row.to_hash.merge({:owner_id => owner.id}))
      end
    rescue Exception => e
    end
  end

end
