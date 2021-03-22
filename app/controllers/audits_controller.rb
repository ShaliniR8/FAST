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
  end


  def create
    @audit = Audit.create(params[:audit])
    redirect_to audit_path(@audit), flash: {success: "Audit created."}
  end


  def edit
    load_options
    @fields = Audit.get_meta_fields('form')
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

end
