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
  before_filter :set_table_name, :login_required
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

  before_filter(only: [:new])    {set_parent_type_id(:finding)}
  before_filter(only: [:create]) {set_parent(:finding)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @finding)}

  include Concerns::Mobile # used for [method]_as_json

  def define_owner
    @class = Object.const_get('Finding')
    @owner = @class.find(params[:id])
    @i18nbase = 'sa.finding'
  end


  def set_table_name
    @table_name = "findings"
  end


  def new
    load_options
    @fields = Finding.get_meta_fields('form')
    if params[:owner_type].present?
      @parent_old = Object.const_get(params[:owner_type]).find(params[:owner_id])
      @owner = @parent_old.findings.new
    else # from Launch Object
      @owner = Finding.new
    end
    @risk_type = 'Baseline'
    choose_load_special_matrix_form(@owner, 'finding')
  end


  def create
    convert_from_risk_value_to_risk_index

    if params[:finding][:attachments_attributes].present?
      params[:finding][:attachments_attributes].each do |key, attachment|
      # File is a base64 string
        if attachment[:name].present? && attachment[:name].is_a?(Hash)
          file_params = attachment[:name]

          temp_file = Tempfile.new('file_upload')
          temp_file.binmode
          temp_file.write(Base64.decode64(file_params[:base64]))
          temp_file.rewind()

          file_name = file_params[:fileName]
          mime_type = Mime::Type.lookup_by_extension(File.extname(file_name)[1..-1]).to_s

          uploaded_file = ActionDispatch::Http::UploadedFile.new(
            :tempfile => temp_file,
            :filename => file_name,
            :type     => mime_type)

          # Replace attachment parameter with the created file
          params[:finding][:attachments_attributes][key][:name] = uploaded_file
        end
      end
    end

    if params[:owner_type].present?
      @parent_old = Object.const_get(params[:owner_type]).find(params[:owner_id])
      @finding = @parent_old.findings.create(params[:finding])
    else # from Launch Object
      @finding = @parent.findings.create(params[:finding])
    end
    notify_on_object_creation(@finding)
    respond_to do |format|
      format.html { redirect_to @finding, flash: {success: 'Finding created.'} }
      format.json {render :json => { :success => 'Finding Created.' }, :status => 200}
    end
  end


  def edit
    load_options
    @has_status = true
    @risk_type = 'Baseline'
    @fields = Finding.get_meta_fields('form')
    choose_load_special_matrix_form(@owner, 'finding')
    @type = @owner.get_owner
    @users.keep_if{|u| u.has_access(@type, 'edit')}
  end


  # def index
  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   params[:type].present? ? @table = Object.const_get(object_name).preload(@object[:preload]).where(owner_type: params[:type])
  #                          : @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   if params[:advance_search].present?
  #     handle_search
  #   else
  #     @records = records
  #   end
  #   filter_records(object_name, controller_name)
  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_hash['Overdue'] = records.select{|x| x.overdue}
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def show
    @has_status = true
    respond_to do |format|
      format.html do
        load_special_matrix(@owner)
        @type = @owner.get_owner
        @fields = Finding.get_meta_fields('show')
        @true_owner = @owner.find_true_owner
        @finding_edit_access = (@owner.related_users.include? current_user.id) || current_user.has_access(@owner.rule_name, 'edit', admin: CONFIG::GENERAL[:global_admin_default])
      end
      format.json { show_as_json }
    end
  end


  def load_options
    rule = AccessControl.where(action: action_name, entry: 'findings').first
    if rule
      privileges_id = rule.privileges.map(&:id)
      @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    end
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


  def mitigate
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    load_special_matrix_form("finding", 'mitigate', @owner)

    @risk_type = 'Mitigate'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end


  def baseline
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    load_special_matrix_form("finding", 'baseline', @owner)

    @risk_type = 'Baseline'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end
end

