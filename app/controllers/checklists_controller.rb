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

  include Concerns::Mobile # used for [method]_as_json

  def set_table
    @table = Object.const_get('Checklist')
  end

  def index
    @title = 'Checklist Templates'
    # @records = Checklist.includes(:checklist_header).where(:owner_type => 'ChecklistHeader').select { |checklist| checklist.checklist_header.status == 'Published' }
    @records = Checklist.where(:owner_type => 'ChecklistHeader')
    @headers = Checklist.get_meta_fields('index')
    @headers.delete({:field=>"get_owner", :title=>"Source of Input", :num_cols=>12, :type=>"text", :visible=>"index,show", :required=>false})
  end

  def new
    if params[:owner_type].present? && params[:owner_type] != 'ChecklistHeader'
      has_admin_access = current_user.has_access(Object.const_get('Checklist').rule_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default])
      if has_admin_access
        @checklist_templates = @table.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
      else
        addressable_templates = current_user.get_all_checklist_addressable_templates
        @checklist_templates = @table.where(:owner_type => 'ChecklistHeader').keep_if {|t| addressable_templates.include?(t.title)}.map{|x| [x.title, x.id]}.to_h
      end
    else
      @checklist_templates = @table.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
    end
    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h
    @owner = Object.const_get("#{params[:owner_type]}").find(params[:owner_id]) rescue nil
    render :partial => 'form'
  end

  def create
    if params[:commit].present? && params[:commit] == 'CreateChecklist'
      create_audit_from_checklist(params, true)
    else
      @owner = Object.const_get("#{params[:checklist][:owner_type]}").find(params[:checklist][:owner_id])
      if %w[VpIm JobAid].include? @owner.class.name
        @owner = @owner.becomes(Im)
        params[:checklist][:owner_type] = 'Im'
      end
      @record = @table.create(params[:checklist])

      if params[:checklist][:owner_type] == 'ChecklistHeader'
        AccessControl.get_checklist_template_opts.map { |disp, db_val|
          AccessControl.new({
            list_type: 1,
            action: db_val,
            entry: @record[:title],
            viewer_access: 1
          }).save
        }
      end

      if params[:checklist_upload].present?
        @upload = File.open(params[:checklist_upload].tempfile)
        case params[:checklist_upload].tempfile.content_type
        when "application/xml", "text/xml"
          upload_xml(@upload, @record)
        else
          upload_csv(@upload, @record)
        end
        @record.assign_row_orders
      end
      redirect_to @record.owner_type == 'ChecklistHeader' ? @record : @owner
    end
  end


  def create_audit_from_checklist(params, from_mobile_app)
    if from_mobile_app
      param_sym = 'checklists_attributes'.to_sym
    else
      param_sym = 'checklist'.to_sym
    end

    if params[param_sym].present?
      if params[param_sym][:id].present?
        params[param_sym].delete(:id)
      end

      params[param_sym][:checklist_rows_attributes].each do |row_key, row_attributes|

        if row_attributes[:attachments_attributes].present?

          row_attributes[:attachments_attributes].each do |att_key, attachment|

            # File is a base64 string
            if attachment[:name].present? && attachment[:name].is_a?(Hash)
              file_params = attachment[:name]

              temp_file = Tempfile.new('file_upload')
              temp_file.binmode
              temp_file.write(Base64.decode64(file_params[:base64]))
              temp_file.rewind()

              file_name = file_params[:fileName]
              mime_type = Mime::Type.lookup_by_extension(File.extname(file_name)[1..-1]).to_s

              uploaded_file = ActionDispatch::Http::UploadedFile.new(
                :tempfile => temp_file,
                :filename => file_name,
                :type     => mime_type)

              # Replace attachment parameter with the created file
              params[param_sym][:checklist_rows_attributes][row_key][:attachments_attributes][att_key][:name] = uploaded_file
            end
          end
        end
      end
    end

    attributes = params[param_sym]
    checklist_template = Checklist.find(params[:id])
    new_checklist = checklist_template.dup
    new_checklist.id = nil
    new_checklist.template_id = checklist_template.id
    new_checklist.owner_type = 'Audit'
    saved = new_checklist.save
    if saved
      new_checklist.checklist_rows = []
      checklist_template.checklist_rows.each do |row|
        new_row = row.dup
        new_row.id = nil
        new_row.checklist_id = new_checklist.id
        row_saved = new_row.save
        if row_saved
          new_row.checklist_cells = []
          row.checklist_cells.each do |cell|
            new_cell = cell.dup
            new_cell.id = nil
            new_cell.checklist_row_id = new_row.id
            cell_saved = new_cell.save
            if cell_saved
              new_row.checklist_cells << new_cell
            else
              render :json => { success: 'Could not create audit from checklist' }
            end
          end
          new_row.save
        else
          render :json => { success: 'Could not create audit from checklist' }
        end
        new_checklist.checklist_rows << new_row if new_row.checklist_cells.size > 0
      end
      final_save = new_checklist.save
      if final_save
        param_row_keys = attributes[:checklist_rows_attributes].keys

        new_checklist.checklist_rows.each_with_index do |row, row_index|
          attributes[:checklist_rows_attributes][row.id.to_s] = attributes[:checklist_rows_attributes].delete(param_row_keys[row_index].to_s)
          attributes[:checklist_rows_attributes][row.id.to_s][:id] = row.id.to_s
        end

        new_checklist.checklist_rows.each do |row|
          attributes[:checklist_rows_attributes].each do |key, value|
            if key.to_s == row.id.to_s
              param_cell_keys = value[:checklist_cells_attributes].keys rescue nil
              if param_cell_keys.present?
                new_cell_keys = row.checklist_cells.map(&:id)
                new_cell_keys.each_with_index do |new_cell_key, cell_index|
                  if from_mobile_app
                    value[:checklist_cells_attributes][new_cell_key.to_s] = value[:checklist_cells_attributes].delete(param_cell_keys[cell_index].to_s)
                    value[:checklist_cells_attributes][new_cell_key.to_s][:id] = new_cell_key.to_s
                    if value[:checklist_cells_attributes][new_cell_key.to_s][:value].is_a?(Array)
                      value[:checklist_cells_attributes][new_cell_key.to_s][:value] = value[:checklist_cells_attributes][new_cell_key.to_s][:value].join(';')
                    end
                  else
                    if param_cell_keys.include?(cell_index.to_s)
                      value[:checklist_cells_attributes][new_cell_key.to_s] = value[:checklist_cells_attributes].delete(cell_index.to_s)
                      value[:checklist_cells_attributes][new_cell_key.to_s][:id] = new_cell_key.to_s
                      if value[:checklist_cells_attributes][new_cell_key.to_s][:value].is_a?(Array)
                        value[:checklist_cells_attributes][new_cell_key.to_s][:value] = value[:checklist_cells_attributes][new_cell_key.to_s][:value].join(';')
                      end
                    end
                  end
                end
              end
            end
          end
        end

        new_checklist.update_attributes(attributes)

        audit_title = "Audit created on #{Time.now.to_date} to address checklist #{new_checklist.title} BY #{current_user.full_name}"
        audit = Audit.create({title: audit_title, responsible_user_id: current_user.id, created_by_id: current_user.id, status: 'Assigned', open_date: Time.now})
        new_checklist.owner_id = audit.id

        audit.checklists = []
        new_checklist.save
        audit.checklists << new_checklist
        audit.save

        if from_mobile_app
          render :json => { success: 'Created Audit' }
        else
          redirect_to audit_path(audit), flash: {success: 'Created Audit'}
        end
      else
        if from_mobile_app
          render :json => { success: 'Could not create audit from checklist' }
        else
          redirect_to checklists_path, flash: {danger: 'Could not create audit from checklist'}
        end
      end
    else
      if from_mobile_app
        render :json => { success: 'Could not create audit from checklist' }
      else
        redirect_to checklists_path, flash: {danger: 'Could not create audit from checklist'}
      end
    end
  end


  def edit
    @record = @table.includes(
      checklist_rows: { checklist_cells: :checklist_header_item },
      checklist_header: :checklist_header_items,
    ).find(params[:id])
    render :partial => 'edit'
  end


  def update
    if params[:checklist][:page_view_checklist].present? || params[:checklist][:page_view_checklist] == ''
      
      # # Handle attachments
      # if params[:checklist][:checklist_rows_attributes].present?
      #   params[:checklist][:checklist_rows_attributes].keys.each do |row_id|
      #     if params[:checklist][:checklist_rows_attributes][row_id.to_s].present?
      #       ChecklistRow.find(row_id).update_attributes(params[:checklist][:checklist_rows_attributes][row_id])
      #     end
      #   end
      # end
      
      #
      @record = @table.find(params[:id])
      if params[:autosave] == 'true'
        cell_ids = @record.checklist_rows.map(&:checklist_cells).flatten.map(&:id)
        params.each do |key, val|
          if cell_ids.include? key.to_i
            value = val.gsub('ccc', ";").gsub(";;", '')
            ChecklistCell.find(key).update_attribute(:value, value)
          end
        end

        render js: "alert('Updated!');"
      else
        page_view_checklist = JSON.parse  params[:checklist][:page_view_checklist] rescue page_view_checklist = []
        page_view_checklist.each do |_, page|
          page.each do |data|
            value = data['value'].gsub(";;", '')
            ChecklistCell.find(data['id']).update_attribute(:value, value)
          end
        end
        redirect_to @record.owner_type == 'ChecklistHeader' ? @record : @record.owner rescue redirect_to @record.owner.owner
      end
    else
      # reset checklist cell value when data type is changed
      if params[:checklist].present? && params[:checklist][:checklist_rows_attributes].present?
        params[:checklist][:checklist_rows_attributes].each do |key, checklist_row|
          if checklist_row[:checklist_cells_attributes].present?
            checklist_row[:checklist_cells_attributes].each do |key, checklist_cell|
              ChecklistCell.find(checklist_cell[:id]).update_attribute(:value, '') if checklist_cell[:data_type].present? && checklist_cell[:id].present?
            end
          end
        end
      end

      if params[:template_names].present?
        template_id = Checklist.where(owner_type: 'ChecklistHeader').where(title: (params[:template_names])).first.id
        params[:checklist][:template_id] = template_id
      end

      if params[:commit].present? && params[:commit] == 'Create Audit'
        create_audit_from_checklist(params, false)
      else
        @record = @table.find(params[:id])
        updated_name = params[:checklist][:title]
        # Assignee update
        if params.key?(:assignee_names)
          user = User.find_by_full_name(params[:assignee_names])
          if user.present?
            params[:checklist][:assignee_ids] = user.id if user.present?
          else
            params[:checklist][:assignee_ids] = nil
          end
        else
          params[:checklist].delete(:assignee_ids) if params[:checklist].present? && params[:checklist].key?(:assignee_ids)
        end

        # TODO: refactor needed
        if params[:checklist].present? && params[:checklist][:checklist_rows_attributes].present?
          params[:checklist][:checklist_rows_attributes].each do |x, y|
            next if y[:checklist_cells_attributes].nil? # when update only attachments
            y[:checklist_cells_attributes].each do |m, n|
              n.each do |key, value|
                if value.is_a?(Array)
                  n[:value].delete("")
                  n[:value] = n[:value].join(";")
                end
              end
            end
          end

          params[:checklist][:checklist_rows_attributes].each do |a, b|
            if b[:attachments_attributes].present?
              b[:attachments_attributes].each do |c, d|
                if d['_destroy'].present? && d['_destroy'].to_i == 1
                  obj = Attachment.find(d['id']) rescue nil
                  if obj.nil?
                    b[:attachments_attributes].delete(c)
                  end
                end
              end
            end
          end
        end
        if @record[:owner_type] == 'ChecklistHeader' && @record[:title] != updated_name
          AccessControl.where(entry: @record[:title]).update_all(entry: updated_name)
        end
        
        @record.update_attributes(params[:checklist])
        if @record.owner.present? && (%w[VpIm JobAid].include? @record.owner.class.name)
          @record.owner = @record.owner.becomes(Im)
        end
        redirect_to @record.owner_type == 'ChecklistHeader' ? @record : @record.owner rescue redirect_to @record.owner.owner
      end
    end
  end


  def show
    respond_to do |format|
      format.html do
        @fields = @table.get_meta_fields('show')
        @record = @table.includes(
          checklist_rows: { checklist_cells: :checklist_header_item },
          checklist_header: :checklist_header_items,
        ).find(params[:id])
        @is_template = @record.owner_type == "ChecklistHeader"


        # Check Access Control
        template_name = Checklist.find(@record.template_id).title rescue @record.title
        has_access = current_user.has_access(template_name, 'viewable', admin: CONFIG::GENERAL[:global_admin_default]) ||
                     current_user.has_access('checklist', 'admin', admin: CONFIG::GENERAL[:global_admin_default]) || (current_user.admin? && @is_template)
        redirect_to errors_path unless has_access
      end
      format.json { show_as_json }
    end
  end


  def address
    @record = @table.includes(
      checklist_rows: { checklist_cells: [:checklist_header_item, :checklist_row] },
      checklist_header: :checklist_header_items,
    ).find(params[:id])
  end


  def select_checklists_raw
    has_admin_access = current_user.has_access(Object.const_get('Checklist').rule_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default])
    if has_admin_access
      @checklist_template_list = @table.where(:owner_type => 'ChecklistHeader').keep_if { |t| t.table_view }
    else
      addressable_templates = current_user.get_all_checklist_addressable_templates
      @checklist_template_list = @table.where(:owner_type => 'ChecklistHeader').keep_if {|t| addressable_templates.include?(t.title)}.keep_if { |t| t.table_view }
    end
  end


  def address_raw
    @record = @table.includes(
      checklist_rows: { checklist_cells: [:checklist_header_item, :checklist_row] },
      checklist_header: :checklist_header_items,
    ).find(params[:template])
    # @record.template_id = params[:template]
    # @record.save

    @record
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
    if %w[VpIm JobAid].include? owner.class.name
      owner = owner.becomes(Im)
    end

    checklist_name = checklist.title
    AccessControl.where(entry: checklist_name).map(&:destroy) if checklist.owner_type == 'ChecklistHeader'
    checklist.destroy
    redirect_to owner.class.name == 'ChecklistHeader' ? checklists_path : owner
  end


  def export
    @record = @table.includes(
                checklist_rows: :checklist_cells,
                checklist_header: :checklist_header_items)
      .find(params[:id])
  end

  def add_template
    owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    template = @table.preload(checklist_rows: :checklist_cells).find(params[:id])

    Checklist.transaction do
      new_checklist = template.clone

      new_checklist.template_id = template.id
      if owner.class.name == "SafetySurvey"
        owner.checklist = new_checklist
      else
        owner.checklists << new_checklist
      end

      template.checklist_rows.each do |row|
        new_row = row.clone
        new_checklist.checklist_rows << new_row
        row.checklist_cells.each{ |cell| new_row.checklist_cells << cell.clone }
      end

      large_page_checklist = new_checklist.checklist_rows[0].checklist_cells.size > 11
      new_checklist.update_attribute(:table_view, false) if large_page_checklist
    end

    respond_to do |format|
      format.js { render inline: 'location.reload()' }
    end
  end


  private

  def upload_csv(upload, owner)
    checklist_header_items = owner.checklist_header.checklist_header_items
    has_header_col = checklist_header_items.length < CSV.read(upload, headers: true, encoding: "ISO8859-1:UTF-8").headers.length
    begin
      Checklist.transaction do
        CSV.foreach(upload, headers: true, encoding: "ISO8859-1:UTF-8") do |csv_row|
          csv_row = csv_row.fields
          is_header = csv_row.last
          checklist_row = ChecklistRow.create({
            checklist_id: owner.id,
            created_by_id: current_user.id,
            is_header: has_header_col && is_header && (is_header.upcase == 'Y' || is_header.upcase == 'YES')
          })

          checklist_header_items.each_with_index do |header_item, index|
            csv_cell_value = csv_row[index]
            if csv_cell_value.present?
              csv_cell_value.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
            end
            cell = ChecklistCell.new({
              checklist_header_item_id: checklist_header_items[index].id
            })
            if header_item.data_type.match /radio|dropdown/
              cell.options = csv_cell_value || checklist_header_items[index].options
            else
              cell.value = csv_cell_value
            end
            cell.data_type = header_item.data_type
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
