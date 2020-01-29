class HazardsController < ApplicationController

  before_filter :set_table_name,:login_required
  before_filter :define_owner, only: [:interpret]

  def define_owner
    @class = Object.const_get('Hazard')
    @owner = Hazard.find(params[:id])
  end


  def set_table_name
    @table_name = "hazards"
  end



  def index
    @adv_only = true
    @table = Object.const_get("Hazard")
    @title = "Hazards"
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
    if params[:status].present?
       @records = @records.select{|x| x.status == params[:status]}
      @title += " : #{params[:status]}"
    end
    @records = @records.select{|rec| params[:departments].include?(rec.departments)} if params[:departments].present?
    @headers = @table.get_meta_fields('index')
    @table_name = "hazards"
    if !current_user.has_access('hazards', 'admin', admin: true, strict: true)
      hazards = Hazard.includes(:sra)
      cars = hazards.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Review', 'Pending Approval', 'Completed'], current_user.id)
      cars += hazards.where('approver_id = ?', current_user.id)
      cars += Hazard.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
  end



  def show
    @hazard = Hazard.find(params[:id])
    @i18nbase = 'srm.hazard'
    @root_cause_headers = HazardRootCause.get_headers
    load_options
    @fields = Hazard.get_meta_fields('show')
    load_special_matrix(@hazard)
  end



  def new
    @hazard = Hazard.new
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    load_options
    @fields = Hazard.get_meta_fields('form')
    load_special_matrix_form("hazard", "baseline", @hazard)
  end



  def create
    @hazard = Hazard.create(params[:hazard])
    @hazard.status = 'New'
    @hazard.save
    redirect_to @hazard
  end



  def edit
    @hazard = Hazard.find(params[:id])
    @owner = @hazard
    load_options
    @fields = Hazard.get_meta_fields('form')
    load_special_matrix_form("hazard", "baseline", @hazard)
  end




  def update
    transaction = true
    @owner = Hazard.find(params[:id])

    case params[:commit]
    when 'Assign'
      @owner.update_attributes(params[:hazard])
      notify(@owner, notice: {
        users_id: @owner.responsible_user.id,
        content: "Hazard ##{@owner.id} has been assigned to you."},
        mailer: true, subject: 'Hazard Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner, notice: {
          users_id: @owner.approver.id,
          content: "Hazard ##{@owner.id} needs your Approval."},
          mailer: true, subject: 'Hazard Pending Approval')
      else
        @owner.close_date = Time.now rescue nil
      end
    when 'Reject'
      notify(@owner, notice: {
        users_id: @owner.responsible_user.id,
        content: "Hazard ##{@owner.id} was Rejected by the Final Approver."},
        mailer: true, subject: 'Hazard Reject') if @owner.responsible_user
    when 'Approve'
      @owner.close_date = Time.now rescue nil
      notify(@owner, notice: {
        users_id: @owner.responsible_user.id,
        content: "Hazard ##{@owner.id} was Approved by the Final Approver."},
        mailer: true, subject: 'Hazard Approved') if @owner.responsible_user
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:hazard][:status]}"
      params[:hazard][:close_date] = params[:hazard][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    @owner.update_attributes(params[:hazard])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    redirect_to hazard_path(@owner)
  end



  def complete
    hazard = Hazard.find(params[:id])
    unless hazard.can_complete?(current_user)
      redirect_to hazard_path(hazard), flash: { error: "Unable to #{params[:status]} hazard." }
      return
    end
    hazard.status = params[:status]
    hazard.close_date = Time.now
    Transaction.build_for(
      hazard,
      params[:status],
      current_user.id,
    )
    hazard.save
    redirect_to hazard_path(hazard)
  end

  def override_status
    @owner = Hazard.find(params[:id]).becomes(Hazard)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def load_options
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    risk_matrix_initializer
  end
  helper_method :load_options



  def destroy
    hazard=Hazard.find(params[:id])
    hazard.destroy
    redirect_to hazards_path, flash: {danger: "Hazard ##{params[:id]} deleted."}
    #redirect_to root_url
  end



  def new_risk_control
    @hazard = Hazard.find(params[:id])
    @risk_control = RiskControl.new
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable && u.has_access('sras', 'edit')}
    @headers = User.get_headers
    @control_types = RiskControl.get_types
    @fields = RiskControl.get_meta_fields('form')
    render :partial => "new_risk_control"
  end


  def new_attachment
    @owner=Hazard.find(params[:id])
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end


  # Following are functions related to trending the root causes.
  def root_cause_trend
    @records = Hazard.find(:all)
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| puts x.created_at; x.created_at >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.created_at <= @end_date}
    end
    @table = Object.const_get("Hazard")
    @headers = @table.get_headers
    @categories = CauseOption.find(1).children.keep_if{|x| !x.hidden?}

    if !params[:all_categories].present?
      if params[:category_id].present?
        @root = CauseOption.find(params[:category_id])
        @ancestor_ids = CauseOption.find(params[:category_id]).ancestors.map(&:id)
      else
        @root = CauseOption.find(1)
      end
      @root_causes = HazardRootCause
        .includes(:cause_option)
        .where(owner_id: @records.map(&:id))
        .keep_if{|x| x.cause_option.ancestors.map(&:id).include?(@root.id)}
        .group_by{|x| (x.cause_option.ancestors.map(&:id) & @root.children.map(&:id)).first}
        .map {|x, xs| [CauseOption.find(x), xs.map{|c| c.hazard}.uniq.length] }
        .to_h.sort_by{|k, v| v}.reverse!
    else
      @root_causes = HazardRootCause
        .includes(:cause_option)
        .where(owner_id: @records.map(&:id))
        .group_by(&:cause_option_id)
        .map {|x, xs| [CauseOption.find(x), xs.map{|c| c.hazard}.uniq.length] }
        .to_h.sort_by{|k, v| v}.reverse!
    end
  end



  def filter
    redirect_to root_cause_trend_hazards_path(
      :start_date => params[:start_date],
      :end_date => params[:end_date],
      :category_id => params[:category_id],
      :all_categories => params[:all_categories])
  end



  def update_listing_table
    set_table_name
    @table = Object.const_get("Hazard")
    @headers = @table.get_headers
    cause_option_id = params[:cause_option_id]
    puts "#{CauseOption.find(cause_option_id).children.map(&:id)}"
    @records = RootCause
      .where(:cause_option_id => CauseOption.find(cause_option_id).descendants.map(&:id))
      .map{|x| x.owner}.uniq{|x| x.id}
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.created_at >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.created_at <= @end_date}
    end
    render :partial => "hazard_listing"
  end



  def print
    @deidentified = params[:deidentified]
    @hazard = Hazard.find(params[:id])
    print_special_matrix(@hazard)
    html = render_to_string(:template => "/hazards/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Hazard_##{@hazard.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end

  def comment
    @owner = Hazard.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end


  def mitigate
    @owner=Hazard.find(params[:id])
    load_options
    load_special_matrix_form("hazard", "mitigate", @owner)
    if CONFIG::GENERAL[:base_risk_matrix] && AIRLINE_CODE != 'Demo'
      render :partial=>"shared/mitigate"
    else
      render :partial=>"shared/#{AIRLINE_CODE}/mitigate"
    end
  end



  def baseline
    @owner=Hazard.find(params[:id])
    load_options
    load_special_matrix_form("hazard", "baseline", @owner)
    if CONFIG::GENERAL[:base_risk_matrix] && AIRLINE_CODE != 'Demo'
      render :partial=>"shared/baseline"
    else
      render :partial=>"shared/#{AIRLINE_CODE}/baseline"
    end
  end



  def reopen
    @hazard = Hazard.find(params[:id])
    reopen_report(@hazard)
  end


end
