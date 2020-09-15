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
      when "application/xml", "text/xml"
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

# TODO: move helper methods ####################
  def parse_iosa(child, result)
    case child.name
    when 'text'
      result = parse_iosa_text(child, result)
    when 'Emphasis'
      result = parse_iosa_emphasis(child, result)
    when 'nbsp'
      # add new space?
    when 'List'
      result = parse_iosa_list(child, result)
    when 'Para'
      result = parse_iosa_para(child, result)
    end

    return result
  end

  def parse_iosa_para(element, result)
    element.children.each do |child|
      case child.name
      when 'text', 'XRef'
        result = parse_iosa_text(child, result) if child.text != '\n'
      when 'List'
        result = parse_iosa_list(child, result)
      end
    end

    return result
  end

  def parse_iosa_text(element, result)
    result += element.text
  end

  def parse_iosa_emphasis(element, result)
    result += "<b>" + element.children[0].text + "</b>"
  end

  def parse_iosa_list(element, result)
    list_type = element.attributes["type"].value

    case list_type
    when 'lower-roman'
      element.children.each do |item|
        result = parse_iosa_list_item_roman(item, result)
      end
    when 'alphabetical'
      element.children.each do |item|
        result = parse_iosa_list_item_alphabet(item, result)
      end
    when 'bullet'
      element.children.each do |item|
        result = parse_iosa_list_item_bullet(item, result)
      end
    end

    return result
  end

  def parse_iosa_list_item_roman(element, result)
    case element.name
    when 'ListItem'
      if element.children.length == 1

        result += "<br>" if $lower_roman[$index_roman] == 'i'

        result += "&nbsp;&nbsp;" + $lower_roman[$index_roman] + '.&nbsp;&nbsp;' + element.text.to_s + '<br>'
        $index_roman += 1
      else
        temp_str = ''

        element.children.each do |child|
          case child.name
          when 'text'
            temp_str = parse_iosa_text(child, temp_str)
          when 'Emphasis'
            temp_str = parse_iosa_emphasis(child, temp_str)
          when 'List'
            temp_str = parse_iosa_list(child, temp_str)
          end
        end

        result += "&nbsp;&nbsp;" + $lower_roman[$index_roman] + '.&nbsp;&nbsp;' + temp_str + '<br>'
        $index_roman += 1
      end
    end

    return result
  end

  def parse_iosa_list_item_alphabet(element, result)
    case element.name
    when 'List'
      # result = parse_iosa_list(element, result)
    when 'ListItem'
      result += "&nbsp;&nbsp;&nbsp;&nbsp;" + $alphabetical[$index_alphabet] + '.&nbsp;&nbsp;' + element.text.to_s + '<br>'
      $index_alphabet += 1
    end

    return result
  end

  def parse_iosa_list_item_bullet(element, result)
    case element.name
    when 'ListItem'
      result += "&nbsp;&nbsp;" + "- " + element.text.to_s + '<br>'
    end

    return result
  end
###############################################


  def upload_xml(upload, owner)
    begin
      xml = Nokogiri::XML(upload)

      if xml.children[0].name == "Section1"
        questions = xml.xpath("//NumberedPara")
        file = "IOSA"
      else
        questions = xml.xpath("//sasdct:DCTQuestions/sasdct:Question")
        file = "FSIMS"
      end

    rescue Exception => e
      puts e
    end

    case file
    when "IOSA"
      questions_array = []
      $lower_roman  = [ 'i',  'ii',  'iii',  'iv',  'v',  'vi',  'vii',  'viii',  'ix', 'x',
                      'xi', 'xii', 'xiii', 'xiv', 'xv', 'xvi', 'xvii', 'xviii', 'xix', 'xx']
      $alphabetical = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
                      'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't']

      questions.each_with_index do |question, index|

        break if index == 15

        question_hash = []
        question.children.each do |children|

          if children.name == 'Para'
            child_text     = ''
            $index_roman    = 0
            $index_alphabet = 0

            children.children.each do |child|
              child_text = parse_iosa(child, child_text)
            end

            question_hash << [children.name, child_text] if children.elem?
          elsif children.name == 'Guidance'
            child_text     = ''

            children.children.each do |child|
              child_text = parse_iosa(child, child_text) if child.elem?
            end
            question_hash << [children.name, child_text] if children.elem?
          elsif children.name == 'Metadata'
            child_text     = ''

            children.children.each do |child|
              if child.name == 'AuditorActions' && child.elem?
                child.children.each do |aa_checkbox|
                  if aa_checkbox.name == "AACheckbox"
                    child_text += aa_checkbox.text.gsub(/\;/, ":") + ";"
                  end
                end
              end

              child_text = parse_iosa(child, child_text)
            end

            end_str = child_text.rindex(/\;/)
            child_text = child_text[0..(end_str-1)] # remove last ';'
            question_hash << [children.name, child_text] if children.elem?
          else
            question_hash << [children.name, children.text] if children.elem?
          end

        end
        questions_array << question_hash.to_h
      end

      checklist_header_items = owner.checklist_header.checklist_header_items.order("display_order")

      questions_array.each_with_index do |question_list, index|
        checklist_row = ChecklistRow.create({
          :checklist_id => owner.id,
          :created_by_id => current_user.id,
          :is_header => false
        })

        checklist_header_items.each_with_index do |h_item, i|

          case h_item.title
          when 'Number'
            value = question_list['ParaNumber']
          when 'Question'
            value = question_list['Para']
          when 'Auditor Actions'
            value = question_list['Metadata']
          when 'Guidance'
            value = question_list['Guidance']
          else
            value = ''
          end

          ChecklistCell.create({
            :checklist_row_id => checklist_row.id,
            :value => h_item.editable ? "" : value,
            :options => h_item.editable ? value : "",
            :checklist_header_item_id => h_item.id})
        end
      end
    when "FSIMS"
      if questions[0].name == "Question" && questions[0].namespace.prefix == "sasdct"
        questions_array = []
        questions.each_with_index do |question, index|
          question_hash = []
          question.children.each do |children|
            question_hash << [children.name, children.text] if children.elem?
          end
          question_hash << ["QuestionReferences", question.children.children.map{|x| x["SRCLabel"]}.compact.join(", ")]
          question_hash << ["DisplayOrder", question["DisplayOrder"]]
          question_hash << ["QuestionID", question["QuestionID"]]
          question_hash << ["Rev", question["VersionNumber"] + " " + question["VersionDate"]]
          question_hash << ["Status", question["Status"]]
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
                "\n\n<strong>Safety Attribute:</strong> #{question['SafetyAttribute']}".html_safe +
                "\n<strong>Question Type:</strong> #{question['QuestionType']}".html_safe +
                "\n\n<strong>Scoping Attribute:</strong> #{question['ScopingAttribute']}".html_safe +
                "\n<strong>Rev.</strong> #{question['Rev']}".html_safe +
                "\n\n<strong>QID:</strong> #{question['QuestionID']}".html_safe +
                "\n<strong>Response Details:</strong> #{question['ResponseDetails']}".html_safe +
                "\n<strong>Status:</strong> #{question['Status']}".html_safe

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
  end
end
