# Current version of Ruby (2.1.1p76) and Rails (3.0.5) defines send s.t. saving nested attributes does not work
# This method is a "monkey patch" that can fix the issue (tested for Rails 3.0.x)
# Source: https://github.com/rails/rails/issues/11026
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

class SmsActionsController < SafetyAssuranceController
  before_filter :login_required
  before_filter :load_options
  before_filter(only: [:show]) { check_group('sms_action') }
  before_filter :define_owner, only: [
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update
  ]

  def define_owner
    @class = Object.const_get('SmsAction')
    @owner = @class.find(params[:id])
  end


  def new
    @table = 'SmsAction'
    @parent = Object.const_get(params[:owner_type])
      .find(params[:owner_id])
      .becomes(Object.const_get(params[:owner_type])) rescue nil
    @owner = Object.const_get(@table).new
    @owner.open_date = Time.now
    @users = User.where(:disable => 0)
    @headers = User.get_headers
    load_options
    @fields = SmsAction.get_meta_fields('form')
    choose_load_special_matrix_form(@owner, 'sms_action')
  end


  def create
    owner = SmsAction.create(params[:sms_action])
    redirect_to owner.becomes(SmsAction), flash: {success: "Corrective Action created."}
  end


  def index
    @table = Object.const_get("SmsAction")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    @title = 'Corrective Actions'
    if !current_user.has_access('sms_actions','admin', admin: true, strict: true)
      cars = SmsAction.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += SmsAction.where('approver_id = ?',  current_user.id)
      cars += SmsAction.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
  end


  def show
    load_special_matrix(@owner)
    load_options
    @fields = SmsAction.get_meta_fields('show')
    @type = get_car_owner(@owner) || 'sms_actions'
  end



  def edit
    load_options
    @fields = SmsAction.get_meta_fields('form')
    choose_load_special_matrix_form(@owner, 'sms_action')
    @type = get_car_owner(@owner)
    @users.keep_if{|u| u.has_access(@type, 'edit')}
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
    @owner = SmsAction.find(params[:id])
    render :partial => "reassign"
  end

  def update
    transaction = true
    @owner.update_attributes(params[:sms_action])
    send_notification(@owner, params[:commit])
    case params[:commit]
    when 'Reassign'
    when 'Assign'
    when 'Complete'
      if @owner.approver
      else
        @owner.complete_date = Time.now
        @owner.close_date = Time.now
      end
    when 'Reject'
    when 'Approve'
      @owner.complete_date = Time.now
      @owner.close_date = Time.now
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:sms_action][:status]}"
      params[:sms_action][:close_date] = params[:sms_action][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    @owner.update_attributes(params[:sms_action])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.save
    redirect_to sms_action_path(@owner)
  end


  def print
    @deidentified = params[:deidentified]
    @corrective_action = SmsAction.find(params[:id])
    html = render_to_string(:template => "/sms_actions/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Corrective Action##{@corrective_action.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def mitigate
    @owner = SmsAction.find(params[:id]).becomes(SmsAction)
    load_options
    load_special_matrix_form('sms_action', 'mitigate', @owner)
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial => "shared/mitigate"
    else
      render :partial => "shared/#{AIRLINE_CODE}/mitigate"
    end
  end


  def baseline
    @owner = SmsAction.find(params[:id]).becomes(SmsAction)
    load_options
    load_special_matrix_form('sms_action', 'baseline', @owner)
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial => "shared/baseline"
    else
      render :partial => "shared/#{AIRLINE_CODE}/baseline"
    end
  end


end
