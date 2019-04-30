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


class FindingsController < ApplicationController

  before_filter(only: [:show]) { check_group('finding') }


  def new
    load_options
    @fields = Finding.get_meta_fields('form')
    @finding = Object.const_get("#{params[:owner_type]}Finding").new
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    form_special_matrix(@finding, "finding", "severity_extra", "probability_extra")
  end



  def create
    @finding = Object.const_get("#{params[:owner_type]}Finding").create(params[:finding])
    redirect_to @finding.becomes(Finding), flash: {success: "Finding created."}
  end



  def edit
    load_options
    @fields = Finding.get_meta_fields('form')
    @finding = Finding.find(params[:id])
    form_special_matrix(@finding, "finding", "severity_extra", "probability_extra")
    @type = get_finding_owner(@finding)
    @users.keep_if{|u| u.has_access(@type, 'edit')}
  end



  def new_recommendation
    @namespace = "finding"
    @predefined_actions = SmsAction.get_actions
    @departments = SmsAction.departments
    load_options
    @finding = Finding.find(params[:id])
    @recommendation = FindingRecommendation.new
    @fields = FindingRecommendation.get_meta_fields('form')
    render :partial => "new_recommendation"
  end



  def index
    @table = Object.const_get("Finding")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    if !current_user.admin? || current_user.has_access('findings','admin')
      cars = Finding.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Finding.where('approver_id = ?',  current_user.id)
      @records = @records & cars
    end
  end



  def open
    f = Finding.find(params[:id])
    FindingTransaction.create(
      :users_id => current_user.id,
      :action => "Open",
      :owner_id => f.id,
      :stamp => Time.now
    )
    notify(
      f.responsible_user,
      "Finding ##{f.get_id} has been scheduled for you." +
        g_link(finding),
      true,
      "Finding ##{f.get_id} Assigned"
    )
    f.status = "Open"
    f.save
    redirect_to finding_path (f)
  end



  def step
  end



  def show
    @finding = Finding.find(params[:id])
    load_special_matrix(@finding)
    @type = get_finding_owner(@finding)
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





  def assign
    @owner = Finding.find(params[:id]).becomes(Finding)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = Finding.find(params[:id]).becomes(Finding)
    status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
    render :partial=> '/forms/workflow_forms/process', locals: {status: status}
  end

  def approve
    @owner = Finding.find(params[:id]).becomes(Finding)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def override_status
    @owner = Finding.find(params[:id]).becomes(Finding)
    render :partial => '/forms/workflow_forms/override_status'
  end

  def reassign
    @finding = Finding.find(params[:id])
    load_options
    render :partial => "reassign"
  end


  def update
    @owner = Finding.find(params[:id]).becomes(Finding)
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Finding ##{@owner.id} has been Assigned to you." + g_link(@owner),
        true, 'Finding Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner.approver,
          "Finding ##{@owner.id} needs your Approval" + g_link(@owner),
          true, 'Finding Pending Approval')
      else
        @owner.complete_date = Time.now
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Finding ##{@owner.id} was Rejected by the Final Approver" + g_link(@owner),
        true, 'Finding Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Finding ##{@owner.id} was Approved by the Final Approver" + g_link(@owner),
        true, 'Finding Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:finding][:status]}"
    end
    @owner.update_attributes(params[:finding])
    FindingTransaction.create(
        users_id:     current_user.id,
        action:       params[:commit],
        owner_id:     @owner.id,
        content:    transaction_content,
        stamp:        Time.now)
    @owner.save
    redirect_to finding_path(@owner)
  end



  def new_cause
    @finding = Finding.find(params[:id])
    @categories = FindingCause.categories.keys
    render :partial => "new_cause"
  end



  def new_desc
    @finding = Finding.find(params[:id])
    @categories=FindingDescription.categories.keys
    render :partial=>"new_desc"
  end



  def add_causes
    if params[:causes].present?
      params[:causes].each_pair do |k,v|
        if v.present?
          FindingCause.create(:owner_id=>params[:id],:category=>params[:category],:attr=>k,:value=>v)
        end
      end
    end
    redirect_to finding_path(params[:id])
  end



  def add_desc
    if params[:causes].present?
      params[:causes].each_pair do |k,v|
        if v.present?
          FindingDescription.create(
            :owner_id => params[:id],
            :category => params[:category],
            :attr => k,
            :value => v
          )
        end
      end
    end
    redirect_to finding_path(params[:id])
  end



  def new_action
    @namespace = "finding"
    @privileges = Privilege.find(:all)
    @finding = Finding.find(params[:id])
    @action = FindingAction.new
    @action.open_date = Time.now
    @departments = SmsAction.departments
    @users = User.find(:all).keep_if{|u| !u.disable}
    @headers = User.get_headers
    @predefined_actions = SmsAction.get_actions
    load_options
    @fields = SmsAction.get_meta_fields('form')
    form_special_matrix(@action, "finding[corrective_actions_attributes][0]", "severity_extra", "probability_extra")
    render :partial => "action"
  end



  def comment
    @owner = Finding.find(params[:id])
    @comment = FindingComment.new
    render :partial => "audits/viewer_comment"
  end



  def destroy
    finding = Finding.find(params[:id])
    finding.destroy
    redirect_to findings_path, flash: {danger: "Finding ##{params[:id]} deleted."}
  end



  def new_attachment
    @owner = Finding.find(params[:id]).becomes(Finding)
    @attachment = FindingAttachment.new
    render :partial => "shared/attachment_modal"
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



  def retract_cause_attributes
    @attributes = FindingCause.categories[params[:category]]
    render :partial => "/findings/attributes"
  end



  def retract_desc_attributes
    @attributes = FindingDescription.categories[params[:category]]
    render :partial => "/findings/attributes"
  end



  def mitigate
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    mitigate_special_matrix("finding", "mitigated_severity", "mitigated_probability")
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/mitigate"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/mitigate"
    end
  end



  def baseline
    @owner = Finding.find(params[:id]).becomes(Finding)
    load_options
    form_special_matrix(@owner, "finding", "severity_extra", "probability_extra")
    if BaseConfig.airline[:base_risk_matrix]
      render :partial => "shared/baseline"
    else
      render :partial => "shared/#{BaseConfig.airline[:code]}/baseline"
    end
  end



  def reopen
    @finding = Finding.find(params[:id]).becomes(Finding)
    reopen_report(@finding)
  end



end

