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

class AuditsController < SafetyAssuranceController
  require 'csv'

  # before_filter :login_required
  before_filter :oauth_load
  before_filter(only: [:show]) { check_group('audit') }
  before_filter :define_owner, only: [
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :launch,
    :show,
    :update,
    :update_checklist_records,
    :upload_checklist,
    :viewer_access,
  ]

  before_filter :set_table_name

  before_filter(only: [:new])    {set_parent_type_id(:audit)}
  before_filter(only: [:create]) {set_parent(:audit)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @audit)}

  include Concerns::Mobile # used for [method]_as_json

  def define_owner
    @class = Object.const_get('Audit')
    @owner = Audit.find(params[:id])
  end


  def set_table_name
    @table_name = "audits"
  end


  def index
    respond_to do |format|
      format.html do
        @object_name = controller_name.classify
        @table_name = controller_name

        @object = CONFIG.hierarchy[session[:mode]][:objects][@object_name]
        @default_tab = params[:status]
        # Datatable Column Info
        @columns = get_data_table_columns(@object_name)
        @column_titles = @columns.map { |col| col[:title] }
        @date_type_column_indices = @column_titles.map.with_index { |val, inx|
          (val.downcase.include?('date') || val.downcase.include?('time')) ? inx : nil
        }.select(&:present?)
        @advance_search_params = params
        render 'forms/index'
      end
      format.json { index_as_json }
    end
  end


  def new
    @owner = Audit.new
    load_options
    @fields = Audit.get_meta_fields('form')

    has_admin_access = current_user.has_access(Object.const_get('Checklist').rule_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default])
    if has_admin_access
      @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
    else
      addressable_templates = current_user.get_all_checklist_addressable_templates
      @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').keep_if {|t| addressable_templates.include?(t.title)}.map{|x| [x.title, x.id]}.to_h
    end

    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h
  end


  def create
    @audit = Audit.create(params[:audit])
    @audit.privileges = [] # Group access feature. Done this so that privileges array does not contain any empty list items.
    @audit.save

    @audit.handle_uniq_custom_id if CONFIG::GENERAL[:custom_uniq_id]

    if CONFIG.sa::GENERAL[:non_recurring_item_checklist]
      @selected_checklists = params[:checklist_templates]
      @checklist_header = params[:checklist_header]
      @checklist_title = params[:checklist_title]
      @checklist_upload = params[:checklist_upload]

      if @selected_checklists
        add_checklist_template_to_item(@selected_checklists, @audit)   
      end 

      if @checklist_header.present?
        create_custom_checklist(@audit, @checklist_header, @checklist_title, @checklist_upload)
      end

    end
    notify_on_object_creation(@audit)
    redirect_to audit_path(@audit), flash: {success: "Audit created."}
  end


  def edit
    @has_status = true
    load_options
    @fields = Audit.get_meta_fields('form')
  end


  def complete
    record = Audit.find(params[:id])
    send_notification(record, 'Complete')
    respond_to do |format|
      format.json { complete_as_json }
    end
  end


  def new_requirement
    @audit = Audit.find(params[:id])
    @requirement = AuditRequirement.new
    @fields = AuditRequirement.get_meta_fields('form')
    load_options
    render :partial => 'requirement'
  end


  def upload_checklist
    if !params[:append].present?
      @owner.clear_checklist
    end
    if params[:checklist].present?
      upload = File.open(params[:checklist].tempfile)
      begin
        CSV.foreach(upload,{
          :headers => :true,
          :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }
          }) do |row|
          AuditItem.create(row.to_hash.merge({:owner_id => @owner.id}))
        end
      rescue Exception => e
        redirect_to audit_path(@owner)
        return
      end
    end
    Transaction.build_for(
      @owner,
      'Upload Checklist',
      current_user.id
    )
    redirect_to audit_path(@owner)
  end


  def add_checklist
    @audit = Audit.find(params[:id])
    render :partial => "/checklist_templates/select_checklist"
  end

  def populate_checklist
    @checklist_template = ChecklistTemplate.find(params[:checklist_template])
    @checklist_template.build_checklist_records(@audit)
    redirect_to audit_path(@audit)
  end


  def new_checklist
    @audit = Audit.find(params[:id])
    @path = upload_checklist_audit_path(@audit)
    render :partial => 'checklist'
  end


  def show
    @has_status = true
    respond_to do |format|
      format.html do
        load_options
        @fields = Audit.get_meta_fields('show')
        @recommendation_fields = Recommendation.get_meta_fields('show')
        @type = 'audits'
        @checklist_headers = AuditItem.get_headers
      end
      format.json { show_as_json }
    end
  end


  def load_options
    @privileges = Privilege.find(:all)
      .keep_if{|p| keep_privileges(p, 'audits')}
      .sort_by!{|a| a.name}
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    @cause_headers = FindingCause.get_headers
    # @audit_types = Audit.get_audit_types
    risk_matrix_initializer
  end
  helper_method :load_options


  def update_checklist
    @audit = Audit.find(params[:id])
    @checklist_headers = AuditItem.get_headers
    render :partial => "update_checklist"
  end


  def update_checklist_records
    render :partial => "checklist_templates/update_checklist_records"
  end


  def download_checklist
    @audit = Audit.find(params[:id])
  end

  def show_finding
    @findings =  ChecklistRow.find(params[:"checklist_row_id"]).findings

    render :partial=>"show_finding"
  end

  private

  def add_checklist_template_to_item(selected_checklists, template)
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
