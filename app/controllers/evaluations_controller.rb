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


  def update
    transaction = true
    send_notification(@owner, params[:commit])
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
      else
        @owner.complete_date = Time.now
        @owner.close_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
    when 'Approve'
      @owner.complete_date = Time.now
      @owner.close_date = Time.now
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:evaluation][:status]}"
      params[:evaluation][:close_date] = params[:evaluation][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    @owner.update_attributes(params[:evaluation])
    @owner.status = update_status || @owner.status
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.save
    redirect_to evaluation_path(@owner)
  end


  def new_requirement
    @audit = Evaluation.find(params[:id])
    @fields = EvaluationRequirement.get_meta_fields('form')
    @requirement = EvaluationRequirement.new
    load_options
    render :partial => 'audits/requirement'
  end


  def create
    evaluation = Evaluation.new(params[:evaluation])
    if evaluation.save
      redirect_to evaluation_path(evaluation), flash: {success: "Evaluation created."}
    end
  end


  def index
    @table = Object.const_get("Evaluation")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    @records = @records.keep_if{|x| x[:template].nil? || !x[:template]}
    if !current_user.has_access('evaluations', 'admin', admin: true, strict: true)
      cars = Evaluation.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Evaluation.where('approver_id = ?',  current_user.id)
      if current_user.has_access('evaluations','viewer')
        Evaluation.where('viewer_access = true').each do |viewable|
          if viewable.privileges.blank?
            cars += [viewable]
          else
            viewable.privileges.each do |privilege|
              current_user.privileges.include? privilege
              cars += [viewable]
            end
          end
        end
      end
      cars += Evaluation.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
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
