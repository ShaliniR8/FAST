class RecurrencesController < ApplicationController

  before_filter :login_required
  before_filter :recurrence_enabled

  def recurrence_enabled
    unless CONFIG.sa::GENERAL[:enable_recurrence]
      redirect_to errors_path
    end
  end


  def child_access_validation(con_name, act_name)
    redirect_to errors_path unless current_user.has_access(con_name.downcase.pluralize, act_name, admin: CONFIG::GENERAL[:global_admin_default])
  end
  helper_method :child_access_validation

  
  def create
    @template = params[:audit] || params[:investigation] || params[:evaluation] || params[:inspection]
    params.each do |key, data|
      case key
        when 'audit'
          @table = Audit
          calculate_due_date('Audit', params)
        when 'investigation'
          @table = Investigation
        when 'evaluation'
          @table = Evaluation
          calculate_due_date('Evaluation', params)
        when 'inspection'
          @table = Inspection
          calculate_due_date('Inspection', params)
        end
    end

    if CONFIG.sa::GENERAL[:recurring_item_checklist]
      @selected_checklists = params[:checklist_templates]
      @checklist_header = params[:checklist_header]
      @checklist_title = params[:checklist_title]
      @checklist_upload = params[:checklist_upload]
    end
  
    template = @table.create(@template)
    template.created_by_id = current_user.id
    template.template = true
    template.save!

    if @selected_checklists
      add_checklist_template_to_recurrence(@selected_checklists, template)   
    end

    if @checklist_header.present?
      create_custom_checklist(template, @checklist_header, @checklist_title, @checklist_upload)
    end
 
    @recurrence = Recurrence.create(params[:recurrence])
    @recurrence.template_id = template.id
    @recurrence.created_by_id = current_user.id
    @recurrence.form_type = @table.name
    @recurrence.save!
    notify_on_object_creation(@recurrence)
    child_access_validation(@table.name,'admin')
    redirect_to recurrence_path(@recurrence), flash: {success: "Recurrent #{@table} created."}
  end


  def edit
    load_options
    @recurrence = Recurrence.find(params[:id])
    @fields = Recurrence.get_meta_fields('form')
    @type = @recurrence.form_type
    if CONFIG.sa::GENERAL[:recurring_item_checklist]
      @fields = Recurrence.get_meta_fields_spawns('form')
    end
    @table = Object.const_get(@type)
    @template = @table.find(@recurrence.template_id)
    @owner = @template
    @template_fields = @table.get_meta_fields('form')
    @days_to_complete = get_days_to_complete(@template, @recurrence)
    child_access_validation(@type,'admin')
  end

  
  def index
    if params.key? :form_type
      child_access_validation(params[:form_type].downcase.pluralize,'index')
      @table = Recurrence.where(form_type: Object.const_get(params[:form_type]))
    else
      redirect_to errors_path unless current_user.global_admin?
      @table = Recurrence
    end
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
  end


  def load_options
    #load_options Equivalent; in Audits, Investigations, Evaluations, and Inspections.
    @privileges = Privilege.find(:all)
    @privileges.keep_if{|p| keep_privileges(p, 'evaluations')}.sort_by!{|a| a.name}
    @plan = {"Yes" => true, "No" => false}
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    @cause_headers = FindingCause.get_headers
    risk_matrix_initializer
  end
  helper_method :load_options


  def new
    load_options
    @recurrence = Recurrence.new
    @fields = Recurrence.get_meta_fields('form')
    @type = params[:form_type]
    @table = Object.const_get(@type)
    @user_id = current_user.id 
    if CONFIG.sa::GENERAL[:recurring_item_checklist]
      @fields = Recurrence.get_meta_fields_spawns('form')
    end
    has_admin_access = current_user.has_access('checklists', 'admin', admin: CONFIG::GENERAL[:global_admin_default])
    if has_admin_access
      @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
    else
      addressable_templates = current_user.get_all_checklist_addressable_templates
      @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').keep_if {|t| addressable_templates.include?(t.title)}.map{|x| [x.title, x.id]}.to_h
    end
    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h
    @template = @table.new
    @template_fields = @table.get_meta_fields('form')
    child_access_validation(@type,'admin')
  end


  def show
    @recurrence = Recurrence.find(params[:id])
    @fields = Recurrence.get_meta_fields('show')
    @type = Object.const_get(@recurrence.form_type)
    @template = @type.find(@recurrence.template_id)

    if CONFIG.sa::GENERAL[:recurring_item_checklist]
      @fields = Recurrence.get_meta_fields_spawns('show')
    end
    @template_fields = @type.get_meta_fields('show')
    @children = @recurrence.children
    child_access_validation(@type.name,'admin')
  end

  def update
    @recurrence = Recurrence.find(params[:id])
    @recurrence.update_attributes(params[:recurrence])
    @type = Object.const_get(@recurrence.form_type)
    @template = @type.find(@recurrence.template_id)
    template = params[:audit] || params[:investigation] || params[:evaluation] || params[:inspection]
    calculate_due_date_updates(@recurrence.form_type, params, @recurrence)
    @template.update_attributes(template)
    child_access_validation(@type.name,'admin')
    redirect_to recurrence_path(@recurrence)
  end

  def destroy
    recurrence = Recurrence.find(params[:id])
    @type = Object.const_get(recurrence.form_type)
    child_access_validation(@type.name,'destroy')
    template = @type.find(recurrence.template_id)
    template.destroy
    recurrence.destroy
    redirect_to "/recurrences?form_type=#{@type}", flash: {danger: "Recurrence ##{params[:id]} deleted."}
  end

 
  private

  def get_days_to_complete(template, recurrence)
    return (template.due_date.to_date - recurrence.next_date).to_i
  end

  def calculate_due_date(type, params)
    if CONFIG.sa::GENERAL[:days_to_complete_instead_of_date]
      if type == 'Audit'
        params[:audit][:due_date] = params[:recurrence][:next_date].to_date + params[:audit][:due_date].to_i.days rescue 0
      elsif type == 'Inspection'
        params[:inspection][:due_date] = params[:recurrence][:next_date].to_date + params[:inspection][:due_date].to_i.days rescue 0
      elsif type == 'Evaluation'
        params[:evaluation][:due_date] = params[:recurrence][:next_date].to_date + params[:evaluation][:due_date].to_i.days rescue 0     
      end
    end
  end

  def calculate_due_date_updates(type, params, recurrence)
    if CONFIG.sa::GENERAL[:days_to_complete_instead_of_date]
      previous_next_date = recurrence.next_date.to_date
      new_next_date = params[:recurrence][:next_date].to_date
      if previous_next_date != new_next_date
        calculate_due_date(type, params)
      elsif type == 'Audit'
          previous_due_date = Audit.where(id: recurrence.template_id).first.due_date rescue nil
          prev_days_to_complete = (previous_due_date.to_date - previous_next_date.to_date).to_i
          params[:audit][:due_date] = previous_due_date.to_date + (params[:audit][:due_date].to_i - prev_days_to_complete).days rescue 0
      elsif type == 'Inspection'
          previous_due_date = Inspection.where(id: recurrence.template_id).first.due_date rescue nil
          prev_days_to_complete = (previous_due_date.to_date - previous_next_date.to_date).to_i
          params[:inspection][:due_date] = previous_due_date.to_date + (params[:inspection][:due_date].to_i - prev_days_to_complete).days rescue 0
      elsif type == 'Evaluation'
          previous_due_date = Inspection.where(id: recurrence.template_id).first.due_date rescue nil
          prev_days_to_complete = (previous_due_date.to_date - previous_next_date.to_date).to_i
          params[:evaluation][:due_date] = previous_due_date.to_date + (params[:evaluation][:due_date].to_i - prev_days_to_complete).days rescue 0
      end
    end
  end

  def add_checklist_template_to_recurrence(selected_checklists, template)
    selected_checklists.each do |id|
      checklist_template = Checklist.preload(checklist_rows: :checklist_cells).find(id)
      Checklist.transaction do
        new_checklist = checklist_template.clone
        template.checklists << new_checklist
        checklist_template.checklist_rows.each do |row|
          new_row = row.clone
          new_checklist.checklist_rows << new_row
          row.checklist_cells.each{ |cell| new_row.checklist_cells << cell.clone }
        end
      end
    end
  end


  def create_custom_checklist(owner, header, title, checklist_upload)
    new_checklist = Checklist.create()
    new_checklist.owner_type = owner.class.name
    new_checklist.owner_id = owner.id
    new_checklist.created_by_id = current_user.id
    new_checklist.checklist_header_id = header
    new_checklist.title = title
    new_checklist.table_view = 1
    if checklist_upload.present?
      @upload = File.open(checklist_upload.tempfile)
      case checklist_upload.tempfile.content_type
      when "application/xml", "text/xml"
        #upload_xml(@upload, @record)
      else
        upload_csv(@upload, new_checklist)
      end
      new_checklist.assign_row_orders
    end
    new_checklist.save!
  end

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

end
