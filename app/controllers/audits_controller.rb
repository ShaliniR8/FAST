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
    :show,
    :update,
    :update_checklist_records,
    :upload_checklist,
    :viewer_access
  ]
  include Concerns::Mobile # used for [method]_as_json

  def define_owner
    @class = Object.const_get('Audit')
    @owner = Audit.find(params[:id])
  end


  def index
    respond_to do |format|
      format.html do
        # @table = Object.const_get("Audit")
        #   .preload(CONFIG.hierarchy[session[:mode]][:objects]['Audit'][:preload])
        # @headers = @table.get_meta_fields('index')
        # @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
        # handle_search
        # filter_audits

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
        filter_audits
        records = @records.to_a & records.to_a if @records.present?

        @records_hash = records.group_by(&:status)
        @records_hash['All'] = records
        @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
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
    audit = Audit.create(params[:audit])
    redirect_to audit_path(audit), flash: {success: "Audit created."}
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


  def update
    transaction = true
    @owner.update_attributes(params[:audit])
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
      transaction_content = "Status overriden from #{@owner.status} to #{params[:audit][:status]}"
      params[:audit][:close_date] = params[:audit][:status] == 'Completed' ? Time.now : nil
    when 'Add Cost', 'Add Contact', 'Add Attachment'
      transaction = false
    end
    # @owner.update_attributes(params[:audit])
    @owner.status = update_status || @owner.status
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content,
        nil,
        current_user,
        session[:platform]
      )
    end
    @owner.save
    respond_to do |format|
      format.html { redirect_to audit_path(@owner) }
      format.json { update_as_json }
    end
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


  def print
    @deidentified = params[:deidentified]
    @audit = Audit.find(params[:id])
    html = render_to_string(:template=>"/audits/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Audit_#{@audit.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def download_checklist
    @audit = Audit.find(params[:id])
  end


private

  def filter_audits
    @records = @records.keep_if{|x| x[:template].nil? || !x[:template]}
    if !current_user.has_access('audits','admin', admin: true, strict: true)
      cars = Audit.where('(status in (:status) AND responsible_user_id = :id) OR approver_id = :id OR created_by_id = :id',
        { status: ['Assigned', 'Pending Approval', 'Completed'], id: current_user[:id] }
      )
      if current_user.has_access('audits','viewer')
        Audit.where('viewer_access = true').each do |viewable|
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
      @records = @records & cars
    end
  end

end
