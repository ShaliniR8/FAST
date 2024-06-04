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
  before_filter :set_table_name, :login_required
  before_filter :load_options
  before_filter(only: [:show]) { check_group('sms_action') }
  before_filter :define_owner, only: [
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update,
  ]

  before_filter(only: [:new])    {set_parent_type_id(:sms_action)}
  before_filter(only: [:create]) {set_parent(:sms_action)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @owner)}

  def define_owner
    @class = Object.const_get('SmsAction')
    @owner = @class.find(params[:id])
  end


  def set_table_name
    @table_name = "sms_actions"
  end


  def new
    @table = 'SmsAction'
    @parent = Object.const_get(params[:owner_type])
      .find(params[:owner_id])
      .becomes(Object.const_get(params[:owner_type])) rescue nil
    @owner = Object.const_get(@table).new
    @owner.open_date = Time.now
    privileges_id = AccessControl.where(action: 'new', entry: 'sms_actions').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    @headers = User.get_headers
    load_options
    @fields = SmsAction.get_meta_fields('form')
    choose_load_special_matrix_form(@owner, 'sms_action')
    @risk_type = 'Baseline'
  end


  def create
    convert_from_risk_value_to_risk_index
    @owner = SmsAction.create(params[:sms_action])
    notify_on_object_creation(@owner)
    redirect_to @owner.becomes(SmsAction), flash: {success: "Corrective Action created."}
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
    load_special_matrix(@owner)
    @has_status = true
    load_options
    @fields = SmsAction.get_meta_fields('show')
    @type = get_car_owner(@owner) || 'sms_actions'
  end



  def edit
    load_options
    @has_status = true
    @fields = SmsAction.get_meta_fields('form')
    choose_load_special_matrix_form(@owner, 'sms_action')
    @type = get_car_owner(@owner)
    privileges_id = AccessControl.where(action: 'edit', entry: 'sms_actions').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    @risk_type = 'Baseline'
  end


  def load_options
    rule = AccessControl.where(action: action_name, entry: 'sms_actions').first
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
    privileges_id = AccessControl.where(action: 'edit', entry: 'sms_actions').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})").uniq
    @owner = SmsAction.find(params[:id])
    render :partial => "reassign"
  end


  def mitigate
    @owner = SmsAction.find(params[:id]).becomes(SmsAction)
    load_options
    load_special_matrix_form('sms_action', 'mitigate', @owner)

    @risk_type = 'Mitigate'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end


  def baseline
    @owner = SmsAction.find(params[:id]).becomes(SmsAction)
    load_options
    load_special_matrix_form('sms_action', 'baseline', @owner)

    @risk_type = 'Baseline'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end
end
