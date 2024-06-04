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

class InspectionsController < SafetyAssuranceController
  before_filter :set_table_name, :login_required
  before_filter(only: [:show]) { check_group('inspection') }
  before_filter :define_owner, only: [
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update,
    :upload_checklist,
    :viewer_access,
  ]

  before_filter(only: [:new])    {set_parent_type_id(:inspection)}
  before_filter(only: [:create]) {set_parent(:inspection)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @inspection)}

  def define_owner
    @class = Object.const_get('Inspection')
    @owner = Inspection.find(params[:id])
  end

  def set_table_name
    @table_name = "inspections"
  end


  def new
    @owner = Inspection.new
    load_options
    @fields = Inspection.get_meta_fields('form')

    has_admin_access = current_user.has_access(Object.const_get('Checklist').rule_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default])
    if has_admin_access
      @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
    else
      addressable_templates = current_user.get_all_checklist_addressable_templates
      @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').keep_if {|t| addressable_templates.include?(t.title)}.map{|x| [x.title, x.id]}.to_h
    end

    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h
  end


  def edit
    load_options
    @has_status = true
    @fields = Inspection.get_meta_fields('form')
  end


  def new_requirement
    @audit = Inspection.find(params[:id])
    @requirement = InspectionRequirement.new
    @fields = InspectionRequirement.get_meta_fields('form')
    load_options
    render :partial => 'audits/requirement'
  end


  def create
    @inspection = Inspection.new(params[:inspection])
    @inspection.save
    if CONFIG.sa::GENERAL[:non_recurring_item_checklist]
      @selected_checklists = params[:checklist_templates]
      @checklist_header = params[:checklist_header]
      @checklist_title = params[:checklist_title]
      @checklist_upload = params[:checklist_upload]

      if @selected_checklists
        add_checklist_template_to_item(@selected_checklists, @inspection)
      end

      if @checklist_header.present?
        create_custom_checklist(@inspection, @checklist_header, @checklist_title, @checklist_upload)
      end

    end
    if @inspection.save
      notify_on_object_creation(@inspection)
      redirect_to inspection_path(@inspection),  flash: {success: "Inspection created."}
    end
  end


  # def index
  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   if params[:advance_search].present?
  #     handle_search
  #   else
  #     @records = records
  #   end
  #   filter_records(object_name, controller_name)
  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_hash['Overdue'] = records.select{|x| x.overdue}
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def show
    load_options
    @has_status = true
    @fields = Inspection.get_meta_fields('show')
    @checklist_headers = InspectionRequirement.get_meta_fields('show')
  end


  def load_options
    rule = AccessControl.where(action: action_name, entry: 'inspections').first
    if rule
      privileges_id = rule.privileges.map(&:id)
      @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    end
      @headers = User.get_headers
      # @departments = Inspection.get_departments
      @plan = {"Yes" => true, "No" => false}
      @supplier = ['External','Internal','Supplier']
      @types = Inspection.select(:inspection_type).uniq
      @station_codes = Inspection.select(:station_code).uniq
      @vendors = Inspection.select(:vendor).uniq
      @frequency = (0..4).to_a.reverse
      @like = Finding.get_likelihood
      @cause_headers = FindingCause.get_headers
      risk_matrix_initializer
  end
  helper_method :load_options


  def upload_checklist
    if !params[:append].present?
      @owner.clear_checklist
    end
    if params[:checklist].present?
      upload = File.open(params[:checklist].tempfile)
      CSV.foreach(upload,{
        :headers => :true,
        :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }
        }) do |row|
        InspectionItem.create(row.to_hash.merge({:owner_id=>@owner.id}))
      end
    end
    Transaction.build_for(
      @owner,
      'Upload Checklist',
      current_user.id
    )
    redirect_to inspection_path(@owner)
  end


  def new_checklist
    @inspection = Inspection.find(params[:id])
      @path = upload_checklist_inspection_path(@inspection)
    render :partial => 'checklist'
  end


  def update_checklist
    @audit = Inspection.find(params[:id])
    @checklist_headers = InspectionItem.get_headers
    render :partial => "audits/update_checklist"
  end


  def download_checklist
    @inspection = Inspection.find(params[:id])
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
    template.save!
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
