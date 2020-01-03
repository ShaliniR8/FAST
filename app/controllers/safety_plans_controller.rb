class SafetyPlansController < ApplicationController
  before_filter :login_required
  before_filter :define_owner, only: [:interpret]

  def define_owner
    @class = Object.const_get('SafetyPlan')
    @owner = SafetyPlan.find(params[:id])
  end


  def index
    @table = Object.const_get("SafetyPlan")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
  end



  def new
    @safety_plan = SafetyPlan.new
    @evaluate = false
    @results = SafetyPlan.results
    @fields = SafetyPlan.get_meta_fields('form')
  end




  def create
    safety_plan = SafetyPlan.create(params[:safety_plan])
    redirect_to safety_plan, flash: {success: "Safety Plan created."}
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
    redirect_to safety_plans_path, flash: {danger: "Safety Plan ##{params[:id]} deleted."}
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



  def print
    @fields = SafetyPlan.get_meta_fields('show')
    @safety_plan = SafetyPlan.find(params[:id])
    html = render_to_string(:template => "/safety_plans/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    send_data pdf.to_pdf, :filename => "Safety_Plan_##{@safety_plan.get_id}.pdf"
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
    safety_plan.date_completed = Time.now
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
