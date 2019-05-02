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


class CorrectiveActionsController < ApplicationController

  before_filter :set_table_name, :login_required



  def set_table_name
    @table_name = "Corrective Actions"
  end




  def new
    @privileges = Privilege.find(:all)
    @corrective_action = CorrectiveAction.new
    if params[:report].present?
      @report = Report.find(params[:report])
    end
    if params[:record].present?
      @record = Record.find(params[:record])
    end
    @fields = CorrectiveAction.get_meta_fields('form')
  end



  def index
    @table = Object.const_get("CorrectiveAction")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    if !current_user.admin?
      cars = CorrectiveAction.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += CorrectiveAction.where('approver_id = ?',  current_user.id)
      @records = @records & cars
    end
  end


  def create
    @owner = CorrectiveAction.new(params[:corrective_action])
    @owner.status = "New"
    if @owner.save
      redirect_to corrective_action_path(@owner), flash: {success: "Corrective Action created."}
    else
      redirect_to new_corrective_action_path
    end
  end

  def show
    @fields = CorrectiveAction.get_meta_fields('show')
    @corrective_action = CorrectiveAction.find(params[:id])
    @report = ''
    @record = ''
    if @corrective_action.report.present?
      @report = display_in_table(@corrective_action.report) ? @corrective_action.report : ''
    end
    if @corrective_action.record.present?
      @record = record_display(@corrective_action.record) ? @corrective_action.record : ''
    end
  end

  def override_status
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def assign
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end


  def complete
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def approve
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end


  def update
    @owner = CorrectiveAction.find(params[:id])
    case params[:commit]
    when 'Assign'
      @owner.assigned_date = Time.now
      notify(@owner.responsible_user,
        "Corrective Action ##{@owner.id} has been Assigned to you." + g_link(@owner),
        true, 'Corrective Action Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner.approver,
          "Corrective Action ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Corrective Action Pending Approval')
      else
        @owner.close_date = Time.now
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Corrective Action ##{@owner.id} has been Rejected by the Final Approver." + g_link(@owner),
        true, 'Corrective Action Rejected')
    when 'Approve'
      @owner.close_date = Time.now
      notify(@owner.responsible_user,
        "Corrective Action ##{@owner.id} has been Approved by the Final Approver." + g_link(@owner),
        true, 'Corrective Action Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:corrective_action][:status]}"
    end
    @owner.update_attributes(params[:corrective_action])
    Transaction.build_for(
      @owner,
      params[:commit],
      current_user.id,
      transaction_content
    )
    @owner.save
    redirect_to corrective_action_path(@owner)
  end




  def edit
    @privileges = Privilege.find(:all)
    @corrective_action = CorrectiveAction.find(params[:id])
    @report = @corrective_action.report
    @record = @corrective_action.record
    @fields = CorrectiveAction.get_meta_fields('form')
  end





  def destroy
    @corrective_action = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    @corrective_action.destroy
    redirect_to corrective_actions_path, flash: {danger: "Corrective Action ##{params[:id]} deleted."}
  end




  def get_term
    all_terms = CorrectiveAction.terms
    @item = all_terms[params[:term].to_sym]
    render :partial => "term"
  end




  def new_attachment
    @owner = CorrectiveAction.find(params[:id]).becomes(CorrectiveAction)
    @attachment = CorrectiveActionAttachment.new
    render :partial => "shared/attachment_modal"
  end




  def print
    @deidentified = params[:deidentified]
    @corrective_action = CorrectiveAction.find(params[:id])
    html = render_to_string(:template => "/corrective_actions/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Corrective_Action_##{@corrective_action.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end



end
