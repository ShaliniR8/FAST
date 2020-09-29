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
  before_filter :login_required
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
    load_special_matrix_form('investigation', 'baseline', @owner)
  end


  def edit
    load_options
    @fields = Investigation.get_meta_fields('form')
    load_special_matrix_form('investigation', 'baseline', @owner)
  end

  def create
    @investigation = Investigation.new(params[:investigation])
    if @investigation.save
      redirect_to investigation_path(@investigation), flash: {success: "Investigation created."}
    end
  end

  def index
    object_name = controller_name.classify
    @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
    @table = Object.const_get(object_name).preload(@object[:preload])
    @default_tab = params[:status]

    records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
    if params[:advance_search].present?
      handle_search
    else
      @records = records
    end
    filter_records(object_name, controller_name)
    records = @records.to_a & records.to_a if @records.present?

    @records_hash = records.group_by(&:status)
    @records_hash['All'] = records
    @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  end



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
end
