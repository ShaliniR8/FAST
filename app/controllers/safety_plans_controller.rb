class SafetyPlansController < ApplicationController
  before_filter :set_table_name, :login_required
  before_filter :define_owner, only: [:interpret]

  before_filter(only: [:new])    {set_parent_type_id(:safety_plan)}
  before_filter(only: [:create]) {set_parent(:safety_plan)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @safety_plan)}

  def define_owner
    @class = Object.const_get('SafetyPlan')
    @owner = SafetyPlan.find(params[:id])
  end

  def set_table_name
    @table_name = "safety_palns"
  end

  # def index
  #   # @table = Object.const_get("SafetyPlan")
  #   # @headers = @table.get_meta_fields('index')
  #   # @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
  #   # handle_search

  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   handle_search if params[:advance_search].present?
  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_hash['Overdue'] = records.select{|x| x.overdue}
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end



  def new
    @safety_plan = SafetyPlan.new
    @evaluate = false
    @results = SafetyPlan.results
    @fields = SafetyPlan.get_meta_fields('form')
  end




  def create
    @safety_plan = SafetyPlan.create(params[:safety_plan])
    redirect_to @safety_plan, flash: {success: "Safety Plan created."}
  end




  def edit
    @safety_plan = SafetyPlan.find(params[:id])
    @evaluate = params[:evaluate]
    @results = SafetyPlan.results
    @evaluate ? @fields = SafetyPlan.get_meta_fields('eval') : @fields = SafetyPlan.get_meta_fields('form')
  end



  def update
    transaction = true
    @owner = SafetyPlan.find(params[:id])
    case params[:commit]
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:safety_plan][:status]}"
      params[:safety_plan][:close_date] = params[:safety_plan][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    @owner.update_attributes(params[:safety_plan])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    redirect_to @owner
  end



  def destroy
    safety_plan = SafetyPlan.find(params[:id])
    safety_plan.destroy
    redirect_to safety_plans_path(status: 'All'), flash: {danger: "Safety Plan ##{params[:id]} deleted."}
  end



  def show
    @safety_plan=SafetyPlan.find(params[:id])
    @fields=SafetyPlan.get_meta_fields('show')
  end


  def new_attachment
    @owner=SafetyPlan.find(params[:id])
    @attachment=Attachment.new
    @evaluate=params[:evaluate]
    render :partial=>"shared/attachment_modal"
  end


  def comment
    @owner = SafetyPlan.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end

  def complete
    safety_plan=SafetyPlan.find(params[:id])
    Transaction.build_for(
      safety_plan,
      'Complete',
      current_user.id
    )
    safety_plan.status="Completed"
    safety_plan.close_date = Time.now
    if safety_plan.save
      redirect_to safety_plan_path(safety_plan)
    end
  end

  def override_status
    @owner = SafetyPlan.find(params[:id]).becomes(SafetyPlan)
    render :partial => '/forms/workflow_forms/override_status'
  end



  def reopen
    @safety_plan = SafetyPlan.find(params[:id])
    reopen_report(@safety_plan)
  end

end
