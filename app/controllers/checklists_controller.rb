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

  before_filter :login_required, :set_table

  def set_table
    @table = Object.const_get('Checklist')
  end

  def index
    @title = 'Checklist Templates'
    @records = @table.where(:owner_type => 'ChecklistHeader')
    @headers = Checklist.get_meta_fields('index')
  end

  def new
    @checklist_templates = @table.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h
    @owner = Object.const_get("#{params[:owner_type]}").find(params[:owner_id]) rescue nil
    render :partial => 'form'
  end

  def create
    @owner = Object.const_get("#{params[:checklist][:owner_type]}").find(params[:checklist][:owner_id])
    @record = @table.create(params[:checklist])
    if params[:checklist_upload].present?
      @upload = File.open(params[:checklist_upload].tempfile)
      case params[:checklist_upload].tempfile.content_type
      when "application/xml"
        upload_xml(@upload, @record)
      else
        upload_csv(@upload, @record)
      end
    end
    redirect_to @record.owner_type == 'ChecklistHeader' ? @record : @owner
  end


  def edit
    @record = @table.find(params[:id])
    render :partial => 'edit'
  end


  def update
    @record = @table.find(params[:id])
    @record.update_attributes(params[:checklist])
    redirect_to @record.owner_type == 'ChecklistHeader' ? @record : @record.owner
  end


  def show
    @fields = @table.get_meta_fields('show')
    @record = @table.find(params[:id])
  end


  def start
    @record = @table.find(params[:id])
    render :partial => 'edit'
  end


  def retract_form_upload
    @owner = Object.const_get("#{params[:owner_type]}").find(params[:owner_id])
    @record = @table.new
    @checklist_header = ChecklistHeader.find(params[:checklist_header])
    render :partial => 'retract_form'
  end

  def retract_form_template
    @owner = Object.const_get("#{params[:owner_type]}").find(params[:owner_id])
    @template = @table.find(params[:template_id])
    @checklist_header = @template.checklist_header
    @record = @table.new
    render :partial => 'retract_form'
  end


  def destroy
    checklist = @table.find(params[:id])
    owner = checklist.owner
    checklist.destroy
    redirect_to owner.class.name == 'ChecklistHeader' ? checklists_path : owner
  end


  def export
    @record = @table.find(params[:id])
  end


  private

  def upload_csv(upload, owner)
    checklist_header_items = owner.checklist_header.checklist_header_items
    begin
      CSV.foreach(upload, :headers => true) do |row|
        checklist_row = ChecklistRow.create({:checklist_id => owner.id, :created_by_id => current_user.id})
        checklist_header_items.each_with_index do |header_item, index|
          cell = row[index]
          ChecklistCell.create({
            :checklist_row_id => checklist_row.id,
            :value => cell,
            :checklist_header_item_id => checklist_header_items[index].id})
        end
      end
    rescue Exception => e
    end
  end

  def upload_xml(upload, owner)
    begin
      xml = Nokogiri::XML(upload)
      questions = xml.xpath("//sasdct:DCTQuestions/sasdct:Question")
    rescue Exception => e
      puts e
    end

    questions_array = []
    questions.each_with_index do |question, index|
      question_hash = []
      question.children.each do |children|
        question_hash << [children.name, children.text] if children.elem?
      end
      question_hash << ["QuestionReferences", question.children.children.map{|x| x["SRCLabel"]}.compact.join(", ")]
      question_hash << ["DisplayOrder", question["DisplayOrder"]]
      questions_array << question_hash.to_h
    end

    checklist_header_items = owner.checklist_header.checklist_header_items
    questions_array.each_with_index do |question, index|
      question_number = question["DisplayOrder"]
      text = question["Text"]
      responses = question["QuestionResponses"].gsub("\t", "").split("\n").join(";") rescue ''
      references = question["QuestionReferences"]
      question_bullets = question["QuestionBullets"]
        .gsub("\t", "")
        .split("\n")
        .each_with_index.map{|x, i| "##{i}. #{x}" if x.present?}
        .compact.join("<br>") rescue ''
      text += "<br>#{question_bullets}"

      values = [question_number, text, responses, references]
      checklist_row = ChecklistRow.create({:checklist_id => owner.id, :created_by_id => current_user.id})
      checklist_header_items.each_with_index do |h_item, i|
        value = values[i]
        ChecklistCell.create({
          :checklist_row_id => checklist_row.id,
          :value => h_item.editable ? "" : value,
          :options => h_item.editable ? value : "",
          :checklist_header_item_id => h_item.id})
      end

    end
  end
end
