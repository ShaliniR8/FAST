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


class RiskControlsController < ApplicationController

  before_filter :set_table_name, :login_required
  before_filter :define_owner, only: [:interpret]

  before_filter(only: [:new])    {set_parent_type_id(:risk_control)}
  before_filter(only: [:create]) {set_parent(:risk_control)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @risk_control)}

  def define_owner
    @class = Object.const_get('RiskControl')
    @owner = RiskControl.find(params[:id])
  end


  def set_table_name
    @table_name = "risk_controls"
  end


  # def index
  #   # @table = Object.const_get("RiskControl")
  #   # @headers = @table.get_meta_fields('index')
  #   # @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
  #   # handle_search
  #   # filter_risk_controls

  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   if params[:advance_search].present?
  #     handle_search
  #   else
  #     @records = records
  #   end
  #   filter_risk_controls
  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_hash['Overdue'] = records.select{|x| x.overdue}
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def view_register
    @table = Object.const_get("RiskControl")
    @table_name = "RiskControl"
    @header_labels = ['Hazard', 'Risk Category', 'Control Measures', 'Initial Risk', 'Latest Risk']
    @headers = ['owner_title', 'risk_category', 'title', 'owner_initial_risk', 'owner_residual_risk']
    @title = "Risk Register"
    @adv_path = advanced_search_home_index_path(:table => @table_name, status: 'All')
    @risks = RiskControl.all
  end


  def new
    if params[:owner_type].present?
      @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    else # from Launch Object
      @owner = Object.const_get(params[:parent_type].capitalize.singularize).find(params[:parent_id])
    end
    privileges_id = AccessControl.where(action: 'new', entry: 'risk_controls').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})")
    @risk_control = RiskControl.new
    @fields = RiskControl.get_meta_fields('form')
  end



  def create
    @risk_control = RiskControl.create(params[:risk_control])
    @risk_control.status = 'New'
    @risk_control.save
    notify_on_object_creation(@risk_control)
    redirect_to @risk_control
  end



  def edit
    @has_status = true
    @risk_control = RiskControl.find(params[:id])
    privileges_id = AccessControl.where(action: 'edit', entry: 'risk_controls').first.privileges.map(&:id)
    @users = User.joins(:privileges).where("privileges_id in (#{privileges_id.join(",")})")
    @headers = User.get_headers
    @fields = RiskControl.get_meta_fields('form')
  end

  def assign
    @owner = RiskControl.find(params[:id]).becomes(RiskControl)
    render partial: '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = RiskControl.find(params[:id]).becomes(RiskControl)
    status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
    render partial: '/forms/workflow_forms/process', locals: {status: status}
  end

  def override_status
    @owner = RiskControl.find(params[:id]).becomes(RiskControl)
    render :partial => '/forms/workflow_forms/override_status'
  end

  def approve
    @owner = RiskControl.find(params[:id]).becomes(RiskControl)
    status = params[:commit] == 'approve' ? 'Completed' : 'Assigned'
    render partial: '/forms/workflow_forms/process', locals: {status: status}
  end

  def update
    transaction = true
    @owner = RiskControl.find(params[:id]).becomes(RiskControl)
    transaction_content = params[:risk_control][:closing_comment] rescue nil
    if transaction_content.nil?
      transaction_content = params[:risk_control][:final_comment] rescue nil
    end
    if transaction_content.nil?
      if params[:risk_control][:comments_attributes].present?
        params[:risk_control][:comments_attributes].each do |key, val|
          transaction_content = val[:content] rescue nil
        end
      end
    end

    case params[:commit]
    when 'Assign'
      @owner.update_attributes(params[:risk_control])
      @owner.open_date = Time.now
      notify(@owner, notice: {
        users_id: @owner.responsible_user.id,
        content: "Risk Control ##{@owner.id} has been assigned to you."},
        mailer: true, subject: 'Risk Control Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner, notice: {
          users_id: @owner.approver.id,
          content: "Risk Control ##{@owner.id} needs your Approval."},
          mailer: true, subject: 'Risk Control Pending Approval')
      else
        @owner.close_date = Time.now
      end
    when 'Reject'
      notify(@owner, notice: {
        users_id: @owner.responsible_user.id,
        content: "Risk Control ##{@owner.id} was Rejected by the Final Approver."},
        mailer: true, subject: 'Risk Control Reject') if @owner.responsible_user
    when 'Approve'
      @owner.close_date = Time.now
      notify(@owner, notice: {
        users_id: @owner.responsible_user.id,
        content: "Risk Control ##{@owner.id} was Approved by the Final Approver."},
        mailer: true, subject: 'Risk Control Approved') if @owner.responsible_user
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:risk_control][:status]}"
      params[:risk_control][:close_date] = params[:risk_control][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment', 'Add Cost'
      transaction = false
    end
    @owner.update_attributes(params[:risk_control])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.save
    redirect_to risk_control_path(@owner)
  end


  def comment
    @owner = RiskControl.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end


  def destroy
    risk_control = RiskControl.find(params[:id])
    risk_control.destroy
    redirect_to risk_controls_path(status: 'All'), flash: {danger: "Risk Control ##{params[:id]} deleted."}
  end




  def show
    @has_status = true
    @risk_control = RiskControl.find(params[:id])
    @fields = RiskControl.get_meta_fields('show')
  end




  def new_cost
    @owner = RiskControl.find(params[:id])
    @cost = Cost.new
    render :partial => "forms/new_cost"
  end




  def new_attachment
    @owner=RiskControl.find(params[:id])
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end


  def reopen
    @risk_control = RiskControl.find(params[:id])
    reopen_report(@risk_control)
  end

private

  def filter_risk_controls

    @records = @records.select{|rec| params[:departments].include?(rec.departments)} if params[:departments].present?

    if !current_user.has_access('risk_controls', 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
      rcs = RiskControl.includes(hazard: :sra)
      cars = rcs.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += rcs.where('approver_id = ?',  current_user.id)
      cars += RiskControl.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
  end

end
