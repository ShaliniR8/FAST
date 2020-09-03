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

class EvaluationsController < SafetyAssuranceController
  before_filter :login_required
  before_filter(only: [:show]) { check_group('evaluation') }
  before_filter :define_owner, only: [
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update,
    :upload_checklist,
    :viewer_access
  ]

  before_filter(only: [:new])    {set_parent_type_id(:evaluation)}
  before_filter(only: [:create]) {set_parent(:evaluation)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @evaluation)}

  def define_owner
    @class = Object.const_get('Evaluation')
    @owner = Evaluation.find(params[:id])
  end

  def new
    @owner = Evaluation.new
    load_options
    @fields = Evaluation.get_meta_fields('form')
  end


  def edit
    load_options
    @fields = Evaluation.get_meta_fields('form')
  end


  def print
    @deidentified = params[:deidentified]
    @evaluation = Evaluation.find(params[:id])
    @requirement_headers = EvaluationRequirement.get_meta_fields('show')
    html = render_to_string(:template=>"/evaluations/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Evaluation_##{@evaluation.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end

  def new_requirement
    @audit = Evaluation.find(params[:id])
    @fields = EvaluationRequirement.get_meta_fields('form')
    @requirement = EvaluationRequirement.new
    load_options
    render :partial => 'audits/requirement'
  end


  def create
    @evaluation = Evaluation.new(params[:evaluation])
    if @evaluation.save
      redirect_to evaluation_path(@evaluation), flash: {success: "Evaluation created."}
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
    @records_hash['Overdue'] = records.select{|x| x.overdue}
    @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  end


  def show
    load_options
    @fields = Evaluation.get_meta_fields('show')
    if !@owner.viewer_access && !current_user.has_access('evaluations', 'viewer', admin: true)
      redirect_to errors_path
      return
    end
    @checklist_headers = EvaluationRequirement.get_meta_fields('show')
  end


  def load_options
    @privileges = Privilege.find(:all)
      .keep_if{|p| keep_privileges(p, 'evaluations')}
      .sort_by!{|a| a.name}
    @plan = {"Yes" => true, "No" => false}
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
        EvaluationItem.create(row.to_hash.merge({:owner_id => @owner.id}))
      end
    end
    Transaction.build_for(
      @owner,
      'Upload Checklist',
      current_user.id
    )
    redirect_to evaluation_path(@owner)
  end


  def new_checklist
    @evaluation = Evaluation.find(params[:id])
    @path = upload_checklist_evaluation_path(@evaluation)
    render :partial => 'checklist'
  end


  def update_checklist
    @audit = Evaluation.find(params[:id])
    @checklist_headers = EvaluationItem.get_meta_fields
    render :partial => "audits/update_checklist"
  end


  def download_checklist
    @evaluation = Evaluation.find(params[:id])
  end
end
