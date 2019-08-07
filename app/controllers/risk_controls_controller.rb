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

  before_filter :login_required



  def index
    @table = Object.const_get("RiskControl")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    if !current_user.admin? && !current_user.has_access('risk_controls','admin')
      rcs = RiskControl.includes(hazard: :sra)
      cars = rcs.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += rcs.where('approver_id = ?',  current_user.id)
      cars += RiskControl.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
  end



  def new
    @owner = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @risk_control = RiskControl.new
    @fields = RiskControl.get_meta_fields('form')
  end



  def create
    @risk_control = RiskControl.create(params[:risk_control])
    @risk_control.status = 'New'
    @risk_control.save
    redirect_to @risk_control
  end



  def edit
    @risk_control = RiskControl.find(params[:id])
    @users = User
      .find(:all)
      .keep_if{|u| !u.disable && u.has_access('sras', 'edit')}
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
    case params[:commit]
    when 'Assign'
      @owner.date_open = Time.now
      notify(@owner.responsible_user,
        "Risk Control ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Risk Control Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner.approver,
          "Risk Control ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Risk Control Pending Approval')
      else
        @owner.date_complete = Time.now
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Risk Control ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Risk Control Rejected')
    when 'Approve'
      @owner.date_complete = Time.now
      notify(@owner.responsible_user,
        "Risk Control ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Risk Control Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:risk_control][:status]}"
    when 'Add Attachment'
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
    redirect_to risk_controls_path, flash: {danger: "Risk Control ##{params[:id]} deleted."}
  end




  def show
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



  def print
    @deidentified = params[:deidentified]
    @risk_control = RiskControl.find(params[:id])
    html = render_to_string(:template => "/risk_controls/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Risk_Control_##{@risk_control.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def reopen
    @risk_control = RiskControl.find(params[:id])
    reopen_report(@risk_control)
  end

end
