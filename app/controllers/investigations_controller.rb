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
    :edit,
    :new_attachment,
    :new_contact,
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
    @investigation = Investigation.new
    if params[:record].present?
      @record = Record.find(params[:record])
    end
    @cancel_path = root_url
    if @record.present?
      @cancel_path = record_path(@record)
    end
    load_options
    @fields = Investigation.get_meta_fields('form')
    form_special_matrix(@investigation, "investigation", "severity_extra", "probability_extra")
  end


  def edit
    load_options
    @fields = Investigation.get_meta_fields('form')
    form_special_matrix(@investigation, "investigation", "severity_extra", "probability_extra")
  end


  def update
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
    end
    @owner.update_attributes(params[:investigation])
    @owner.status = update_status || @owner.status
    Transaction.build_for(
      @owner,
      params[:commit],
      current_user.id,
      transaction_content
    )
    @owner.save
    redirect_to investigation_path(@owner)
  end


  def create
    investigation = Investigation.new(params[:investigation])
    if investigation.record_id.present?
      @record = Record.find(investigation.record_id)
      @record.investigation_id = investigation.id
      @record.save
    end
    if investigation.save
      redirect_to investigation_path(investigation), flash: {success: "Investigation created."}

    end
  end

  def index
    @table = Object.const_get("Investigation")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    @records = @records.where('template = 0 OR template IS NULL')
    if !current_user.admin? && !current_user.has_access('investigations','admin')
      cars = Investigation.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Investigation.where('approver_id = ?',  current_user.id)
      if current_user.has_access('investigations','viewer')
        Investigation.where('viewer_access = true').each do |viewable|
          if viewable.privileges.empty?
            cars += [viewable]
          else
            viewable.privileges.each do |privilege|
              current_user.privileges.include? privilege
              cars += [viewable]
            end
          end
        end
      end
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


  def  new_finding
    @audit = Investigation.find(params[:id])
    @finding = InvestigationFinding.new
    @classifications = Finding.get_classifications
    form_special_matrix(@finding, "investigation[findings_attributes][0]", "severity_extra", "probability_extra")
    load_options
    @fields = Finding.get_meta_fields('form')
    render :partial => "audits/finding"
  end


  def new_action
    @namespace = "finding"
    @privileges = Privilege.find(:all)
    @finding = Investigation.find(params[:id])
    @action = SmsAction.new
    @departments = SmsAction.departments
    @users = User.find(:all).keep_if{|u| !u.disable}
    @headers = User.get_headers
    @predefined_actions = SmsAction.get_actions
    load_options
    @fields = SmsAction.get_meta_fields('form')
    form_special_matrix(@action, "investigation[corrective_actions_attributes][0]", "severity_extra", "probability_extra")
    render :partial => "findings/action"
  end


  def new_cost
    @cost = InvestigationCost.new
    @corrective_action = Investigation.find(params[:id])
    render :partial => "sms_actions/new_cost"
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


  def destroy
    Investigation.find(params[:id]).destroy
    redirect_to investigations_path, flash: {danger: "Investigation ##{params[:id]} deleted."}
  end


  def new_cause
    @investigation = Investigation.find(params[:id])
    @categories = InvestigationCause.categories.keys
    render :partial => "new_cause"
  end


  def new_desc
    @finding = Investigation.find(params[:id])
    @categories = InvestigationDescription.categories.keys
    render :partial => "new_desc"
  end


  def add_causes
    if params[:causes].present?
      params[:causes].each_pair do |k,v|
        if v.present?
          InvestigationCause.create(
            :owner_id => params[:id],
            :category => params[:category],
            :attr => k,
            :value => v
          )
        end
      end
    end
    redirect_to investigation_path(params[:id])
  end


  def add_desc
    if params[:causes].present?
      params[:causes].each_pair do |k,v|
        if v.present?
          InvestigationDescription.create(
            :owner_id => params[:id],
            :category => params[:category],
            :attr => k,
            :value => v)
        end
      end
    end
    redirect_to investigation_path(params[:id])
  end


  def retract_cause_attributes
    @attributes = InvestigationCause.categories[params[:category]]
    render :partial => "/findings/attributes"
  end


  def retract_desc_attributes
    @attributes = InvestigationDescription.categories[params[:category]]
    render :partial => "/findings/attributes"
  end


  def mitigate
    @owner = Investigation.find(params[:id])
    mitigate_special_matrix("investigation", "mitigated_severity", "mitigated_probability")
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
    form_special_matrix(@owner, "investigation", "severity_extra", "probability_extra")
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/baseline"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/baseline"
    end
  end


end
