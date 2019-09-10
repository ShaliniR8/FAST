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
    :approve,
    :assign,
    :comment,
    :complete,
    :destroy,
    :edit,
    :new_attachment,
    :new_contact,
    :new_cost,
    :new_signature,
    :new_task,
    :override_status,
    :reopen,
    :show,
    :update,
    :viewer_access

  ]

  def define_owner
    @class = Object.const_get('Investigation')
    @owner = Investigation.find(params[:id])
  end

  def new_recommendation
    @predefined_actions = SmsAction.get_actions
    @departments = SmsAction.departments
    load_options
    @finding = Investigation.find(params[:id])
    @recommendation = Recommendation.new
    @fields = Recommendation.get_meta_fields('form')
    render :partial => "findings/new_recommendation"
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


  def update
    transaction = true
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Investigation ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Investigation Assigned')
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "Investigation ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Investigation Pending Approval')
      else
        @owner.complete_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Investigation ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Investigation Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Investigation ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Investigation Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:investigation][:status]}"
    when 'Add Attachment'
      transaction = false
    end
    @owner.update_attributes(params[:investigation])
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
    redirect_to investigation_path(@owner)
  end


  def create
    investigation = Investigation.new(params[:investigation])
    if investigation.save
      redirect_to investigation_path(investigation), flash: {success: "Investigation created."}
    end
  end

  def index
    @table = Object.const_get("Investigation")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    @records = @records.keep_if{|x| x[:template].nil? || !x[:template]}
    if !current_user.has_access('investigations', 'admin', admin: true, strict: true)
      cars = Investigation.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Investigation.where('approver_id = ?',  current_user.id)
      if current_user.has_access('investigations','viewer')
        Investigation.where('viewer_access = true').each do |viewable|
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
      cars += Investigation.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
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


  def print
    @deidentified = params[:deidentified]
    @investigation = Investigation.find(params[:id])
    html = render_to_string(:template => "/investigations/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Investigation_##{@investigation.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def mitigate
    @owner = Investigation.find(params[:id])
    load_special_matrix_form("investigation", "mitigate", @owner)
    load_options
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/mitigate"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/mitigate"
    end
  end

  def baseline
    @owner = Investigation.find(params[:id])
    load_options
    load_special_matrix_form("investigation", "baseline", @owner)
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/baseline"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/baseline"
    end
  end


end
