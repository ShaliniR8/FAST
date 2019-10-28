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


class FindingsController < SafetyAssuranceController
  before_filter :login_required
  before_filter(only: [:show]) { check_group('finding') }
  before_filter :define_owner, only: [
    :approve,
    :assign,
    :comment,
    :complete,
    :destroy,
    :edit,
    :new_attachment,
    :new_contact,
    :override_status,
    :reopen,
    :show,
    :update,
    :update_checklist
  ]

  def define_owner
    @class = Object.const_get('Finding')
    @owner = @class.find(params[:id])
  end


  def new
    load_options
    @fields = Finding.get_meta_fields('form')
    @parent = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @owner = @parent.findings.new
    choose_load_special_matrix_form(@owner, 'finding')
  end


  def create
    @parent = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @owner = @parent.findings.create(params[:finding])
    redirect_to @owner, flash: {success: 'Finding created.'}
  end


  def edit
    load_options
    @fields = Finding.get_meta_fields('form')
    choose_load_special_matrix_form(@owner, 'finding')
    @type = @owner.get_owner
    @users.keep_if{|u| u.has_access(@type, 'edit')}
  end


  def new_recommendation
    @namespace = 'finding'
    @predefined_actions = SmsAction.get_actions
    @departments = SmsAction.departments
    load_options
    @finding = Finding.find(params[:id])
    @recommendation = Recommendation.new
    @fields = Recommendation.get_meta_fields('form')
    render :partial => "new_recommendation"
  end


  def index
    @table = Object.const_get("Finding")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    if !current_user.has_access('findings','admin', admin: true, strict: true)
      cars = Finding.where('status in (?) AND responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Finding.where('approver_id = ?',  current_user.id)
      cars += Finding.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
  end


  def open
    f = Finding.find(params[:id])
    Transaction.build_for(
      f,
      'Open',
      current_user.id
    )
    notify(
      f.responsible_user,
      "Finding ##{f.get_id} has been scheduled for you." +
        g_link(finding),
      true,
      "Finding ##{f.get_id} Assigned"
    )
    f.status = "Open"
    f.save
    redirect_to finding_path (f)
  end


  def show
    load_special_matrix(@owner)
    @type = @owner.get_owner
  end


  def load_options
    @privileges = Privilege.find(:all)
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable}
    @headers = User.get_headers
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    risk_matrix_initializer
  end
  helper_method :load_options



  def reassign
    @finding = Finding.find(params[:id])
    load_options
    render :partial => "reassign"
  end


  def update
    transaction = true
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Finding ##{@owner.id} has been Assigned to you." + g_link(@owner),
        true, 'Finding Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner.approver,
          "Finding ##{@owner.id} needs your Approval" + g_link(@owner),
          true, 'Finding Pending Approval')
      else
        @owner.complete_date = Time.now
        @owner.close_date = Time.now
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Finding ##{@owner.id} was Rejected by the Final Approver" + g_link(@owner),
        true, 'Finding Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      @owner.close_date = Time.now
      notify(@owner.responsible_user,
        "Finding ##{@owner.id} was Approved by the Final Approver" + g_link(@owner),
        true, 'Finding Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:finding][:status]}"
      params[:finding][:close_date] = params[:finding][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    @owner.update_attributes(params[:finding])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content,
      )
    end
    @owner.save
    redirect_to finding_path(@owner)
  end


  def print
    @deidentified = params[:deidentified]
    @finding = Finding.find(params[:id])
    html = render_to_string(:template=>"/findings/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Finding##{@finding.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def mitigate
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    load_special_matrix_form("finding", 'mitigate', @owner)
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/mitigate"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/mitigate"
    end
  end


  def baseline
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    load_special_matrix_form("finding", 'baseline', @owner)
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/baseline"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/baseline"
    end
  end


end

