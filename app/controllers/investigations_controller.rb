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

class InvestigationsController < SafetyAssuranceController
  before_filter :set_table_name, :login_required
  before_filter(only: [:show]) { check_group('investigation') }
  before_filter :define_owner, only:[
    :destroy,
    :edit,
    :interpret,
    :override_status,
    :new_attachment,
    :show,
    :update,
    :viewer_access,
  ]


  before_filter(only: [:new])    {set_parent_type_id(:investigation)}
  before_filter(only: [:create]) {set_parent(:investigation)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @investigation)}

  def define_owner
    @class = Object.const_get('Investigation')
    @owner = Investigation.find(params[:id])
  end


  def set_table_name
    @table_name = "investigations"
  end


  def new
    @owner = Investigation.new
    if params[:record].present?
      @record = Record.find(params[:record])
    end
    @cancel_path = root_url
    if @record.present?
      @cancel_path = record_path(@record)
    end
    load_options
    @fields = Investigation.get_meta_fields('form')

    @checklist_templates = Checklist.where(:owner_type => 'ChecklistHeader').map{|x| [x.title, x.id]}.to_h
    @checklist_headers = ChecklistHeader.where(:status => 'Published').map{|x| [x.title, x.id]}.to_h

    @risk_type = 'Baseline'
    load_special_matrix_form('investigation', 'baseline', @owner)
  end


  def edit
    @risk_type = 'Baseline'
    load_options
    @fields = Investigation.get_meta_fields('form')
    load_special_matrix_form('investigation', 'baseline', @owner)
  end

  def create
    convert_from_risk_value_to_risk_index
    @investigation = Investigation.create(params[:investigation])
    if CONFIG.sa::GENERAL[:non_recurring_item_checklist]
      @selected_checklists = params[:checklist_templates]
      @checklist_header = params[:checklist_header]
      @checklist_title = params[:checklist_title]
      @checklist_upload = params[:checklist_upload]

      if @selected_checklists
        add_checklist_template_to_item(@selected_checklists, @investigation)   
      end 

      if @checklist_header.present?
        create_custom_checklist(@investigation, @checklist_header, @checklist_title, @checklist_upload)
      end

    end
    if @investigation.save
      notify_on_object_creation(@investigation)
      redirect_to investigation_path(@investigation), flash: {success: "Investigation created."}
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
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def load_options
    @privileges = Privilege.find(:all)
    @privileges.keep_if{|p| keep_privileges(p, 'investigations')}.sort_by!{|a| a.name}
    # @types = Investigation.types
    # @sources = Investigation.sources
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable && u.has_access('investigations', 'edit')}
    @headers = User.get_headers
    @frequency = (0..4).to_a.reverse
    # @departments = Audit.get_departments
    @like = Finding.get_likelihood
    @cause_headers = FindingCause.get_headers
    risk_matrix_initializer
  end
  helper_method :load_options


  def show
    @type = 'investigations'
    @cause_headers = InvestigationCause.get_headers
    @desc_headers = InvestigationDescription.get_headers
    load_options
    @fields = Investigation.get_meta_fields('show')
    @recommendation_fields = Recommendation.get_meta_fields('show')
    load_special_matrix(@investigation)
  end


  def mitigate
    @owner = Investigation.find(params[:id])
    load_special_matrix_form("investigation", "mitigate", @owner)
    load_options

    @risk_type = 'Mitigate'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end

  def baseline
    @owner = Investigation.find(params[:id])
    load_options
    load_special_matrix_form("investigation", "baseline", @owner)

    @risk_type = 'Baseline'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
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
