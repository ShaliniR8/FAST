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
    @record = @table.includes(
      checklist_rows: { checklist_cells: :checklist_header_item },
      checklist_header: :checklist_header_items,
    ).find(params[:id])
    render :partial => 'edit'
  end


  def update
    @record = @table.find(params[:id])

    # TODO: refactor needed
    params[:checklist][:checklist_rows_attributes].each do |x, y| 
      y[:checklist_cells_attributes].each do |m, n| 
        n.each do |key, value| 
          if value.is_a?(Array)
            n[:value].delete("")
            n[:value] = n[:value].join(";")
          end
        end
      end
    end

    @record.update_attributes(params[:checklist])
    redirect_to @record.owner_type == 'ChecklistHeader' ? @record : @record.owner
  end


  def show
    @fields = @table.get_meta_fields('show')
    @record = @table.includes(
      checklist_rows: { checklist_cells: :checklist_header_item },
      checklist_header: :checklist_header_items,
    ).find(params[:id])
  end


  def start
    @record = @table.includes(
      checklist_rows: { checklist_cells: [:checklist_header_item, :checklist_row] },
      checklist_header: :checklist_header_items,
    ).find(params[:id])
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
    checklist = @table.preload(:checklist_rows => :checklist_cells).find(params[:id])
    owner = checklist.owner
    checklist.destroy
    redirect_to owner.class.name == 'ChecklistHeader' ? checklists_path : owner
  end


  def export
    @record = @table.find(params[:id])
  end

  def add_template
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    template = @table.preload(checklist_rows: :checklist_cells).find(params[:id])

    Checklist.transaction do
      new_checklist = template.clone
      owner.checklists << new_checklist

      template.checklist_rows.each do |row|
        new_row = row.clone
        new_checklist.checklist_rows << new_row
        row.checklist_cells.each{ |cell| new_row.checklist_cells << cell.clone }
      end
    end

    respond_to do |format|
      format.js { render inline: 'location.reload()' }
    end
  end


  private

  def upload_csv(upload, owner)
    checklist_header_items = owner.checklist_header.checklist_header_items
    has_header_col = checklist_header_items.length < CSV.read(upload, headers: true).headers.length
    begin
      Checklist.transaction do
        CSV.foreach(upload, headers: true) do |csv_row|
          csv_row = csv_row.fields
          is_header = csv_row.last
          checklist_row = ChecklistRow.create({
            checklist_id: owner.id,
            created_by_id: current_user.id,
            is_header: has_header_col && is_header && (is_header.upcase == 'Y' || is_header.upcase == 'YES')
          })

          checklist_header_items.each_with_index do |header_item, index|
            csv_cell_value = csv_row[index]
            cell = ChecklistCell.new({
              checklist_header_item_id: checklist_header_items[index].id
            })
            if header_item.data_type.match /radio|dropdown/
              cell.options = csv_cell_value || checklist_header_items[index].options
            else
              cell.value = csv_cell_value
            end
            checklist_row.checklist_cells << cell
          end
        end
      end
    rescue Exception => e
      Rails.logger.info e
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
      question_hash << ["QuestionID", question["QuestionID"]]
      header_section = question.children.select{|x| x.name if x.name == "SectionHeaderMLF"}.first.attributes

      question_hash << ["MLFLabel", header_section["MLFLabel"].value]
      question_hash << ["MLFName", header_section["MLFName"].value]

      questions_array << question_hash.to_h
    end

    checklist_header_items = owner.checklist_header.checklist_header_items.order("display_order")

    questions_array.group_by{|x| [x["MLFLabel"], x["MLFName"]]}.each do |(mlflabel, mlfname), question_list|

      checklist_row = ChecklistRow.create({
        :checklist_id => owner.id,
        :created_by_id => current_user.id,
        :is_header => true})

      header_values = [mlflabel, mlfname]

      checklist_header_items.each_with_index do |h_item, i|
        value = header_values[i] rescue ''
        ChecklistCell.create({
          :checklist_row_id => checklist_row.id,
          :value => h_item.editable ? "" : value,
          :options => h_item.editable ? value : "",
          :checklist_header_item_id => h_item.id})
      end


      Checklist.transaction do
        question_list.each do |question|
          question_number = question["DisplayOrder"]
          question_qid = question["QuestionID"]
          question_text = question["Text"]
          responses = question["QuestionResponses"].gsub("\t", "").split("\n").reject(&:empty?).join(";") rescue ''
          references = question["QuestionReferences"] +
            "\n\nQID: #{question['QuestionID']}" +
            "\nSafety Attribute: #{question['SafetyAttribute']}"
          question_bullets = question["QuestionBullets"]
            .split("\n\t\t\t\t")
            .reject(&:empty?)
            .each_with_index.map{|x, i| "##{i+1}. #{x}"}
            .join("\n\t\t\t\t") rescue ''

          question_text += "\n\t\t\t\t#{question_bullets}"

          values = [question_number, question_text, responses, "placeholder for comment", references]
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
  end
end
