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
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update,
  ]

  def define_owner
    @class = Object.const_get('Finding')
    @owner = @class.find(params[:id])
    @i18nbase = 'sa.finding'
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


  def show
    load_special_matrix(@owner)
    @type = @owner.get_owner
    @fields = Finding.get_meta_fields('show')
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
    @owner.update_attributes(params[:finding])
    send_notification(@owner, params[:commit])
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
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
      transaction_content = "Status overriden from #{@owner.status} to #{params[:finding][:status]}"
      params[:finding][:close_date] = params[:finding][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    # @owner.update_attributes(params[:finding])
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
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial => "shared/mitigate"
    else
      render :partial => "shared/#{AIRLINE_CODE}/mitigate"
    end
  end


  def baseline
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    load_special_matrix_form("finding", 'baseline', @owner)
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial => "shared/baseline"
    else
      render :partial => "shared/#{AIRLINE_CODE}/baseline"
    end
  end


end

