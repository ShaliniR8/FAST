class HazardsController < ApplicationController

  before_filter :set_table_name,:login_required



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
    @headers = @table.get_meta_fields('index')
    @table_name = "hazards"
    if !current_user.admin? && !current_user.has_access('sras','admin')
      hazards = Hazard.includes(:sra)
      cars = hazards.where('sras.status in (?) and sras.responsible_user_id = ?',
        ['Assigned', 'Pending Review', 'Pending Approval', 'Completed'], current_user.id)
      cars += hazards.where('sras.approver_id = ? OR sras.reviewer_id = ?',
        current_user.id, current_user.id)
      cars += hazards.where('sras.viewer_access = 1') if current_user.has_access('sras','viewer')
      @records = @records & cars
    end
  end



  def show
    @hazard = Hazard.find(params[:id])
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
    form_special_matrix(@hazard, "hazard", "severity_extra", "probability_extra")
  end



  def create
    @hazard = Hazard.create(params[:hazard])
    @hazard.status = 'New'
    @hazard.save
    redirect_to @hazard
  end



  def edit
    @hazard = Hazard.find(params[:id])
    load_options
    @fields = Hazard.get_meta_fields('form')
    form_special_matrix(@hazard, "hazard", "severity_extra", "probability_extra")
  end




  def update
    @owner = Hazard.find(params[:id])
    case params[:commit]
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:hazard][:status]}"
    end
    @owner.update_attributes(params[:hazard])
    Transaction.build_for(
      @owner,
      params[:commit],
      current_user.id,
      transaction_content
    )
    redirect_to hazard_path(@owner)
  end



  def complete
    hazard = Hazard.find(params[:id])
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



  def new_root_cause
    @hazard = Hazard.find(params[:id])
    @root = CauseOption.find(1)
    @categories = @root.children.keep_if{|x| !x.hidden?}
    render :partial => "/root_causes/new_root_cause"
  end



  def new_root_cause2(first_id=nil, second_id=nil)
    @owner = Hazard.find(params[:owner_id])
    @root = CauseOption.find(1)
    @categories = @root.children.keep_if{|x| !x.hidden?}
    respond_to do |format|
      format.js {render "/root_causes/new_root_cause2", layout: false, :locals => {:first_id => first_id, :second_id => second_id} }
    end
  end



  def add_root_cause
    @owner = Hazard.find(params[:owner_id])
    if params[:root_causes].present?
      if params[:root_causes][:cause_option_id].present?
        root_cause = HazardRootCause.create(
          :owner_id => @owner.id,
          :user_id  => current_user.id,
          :cause_option_id => params[:root_causes][:cause_option_id],
          :cause_option_value => params[:root_causes][:cause_option_value])
        ancestors = root_cause.cause_option.ancestors
        first_id = ancestors[1].id
        second_id = ancestors[2].id
      end
    end
    first_id ||= nil
    second_id ||= nil
    new_root_cause2(first_id, second_id)
  end



  def reload_root_causes
    @hazard = Hazard.find(params[:id])
    @root_cause_headers = HazardRootCause.get_headers
    render :partial => "/root_causes/root_causes_table",
      :locals => {
        :headers => HazardRootCause.get_headers,
        :owner => @hazard,
        :show_btns => true}
  end



  def retract_root_cause_categories
    second_id = params[:second_id] if params[:second_id]
    @cause_option = CauseOption.find(params[:category])
    @categories = @cause_option.children.keep_if{|x| !x.hidden?}.sort_by{|x| x.name}
    render_category = false
    @categories.each do |x|
      if x.children.length > 0
        render_category = true
      end
    end
    if render_category
      if params[:category_only]
        ancestor_ids = params[:ancestor_ids].present? ? params[:ancestor_ids].split(",").map(&:to_i) : []
        render :partial => "/root_causes/select_category_in_trending", :locals => {:ancestor_ids => ancestor_ids}
      else
        render :partial => "/root_causes/new_root_cause_categories", :locals => {:second_id => second_id}
      end
    else
      if params[:category_only]
        false
      else
        @has_option = @categories.length > 0
        render :partial => "/root_causes/new_root_cause_value"
      end
    end
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
        .map {|x, xs| [CauseOption.find(x), xs.length] }
        .to_h.sort_by{|k, v| v}.reverse!
    else
      @root_causes = HazardRootCause
        .includes(:cause_option)
        .where(owner_id: @records.map(&:id))
        .group_by(&:cause_option_id)
        .map {|x, xs| [CauseOption.find(x), xs.length] }
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
      .map{|x| x.hazard}.uniq{|x| x.id}
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
    mitigate_special_matrix("hazard", "mitigated_severity", "mitigated_probability")
    if BaseConfig.airline[:base_risk_matrix]
      render :partial=>"shared/mitigate"
    else
      render :partial=>"shared/#{BaseConfig.airline[:code]}/mitigate"
    end
  end



  def baseline
    @owner=Hazard.find(params[:id])
    load_options
    form_special_matrix(@owner, "hazard", "severity_extra", "probability_extra")
    if BaseConfig.airline[:base_risk_matrix]
      render :partial=>"shared/baseline"
    else
      render :partial=>"shared/#{BaseConfig.airline[:code]}/baseline"
    end
  end



  def reopen
    @hazard = Hazard.find(params[:id])
    reopen_report(@hazard)
  end


end
