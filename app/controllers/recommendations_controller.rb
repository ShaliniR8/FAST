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

class RecommendationsController < ApplicationController

  before_filter(only: [:show]) { check_group('recommendation') }

  def index
    @table = Object.const_get("Recommendation")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    if !current_user.admin? && !current_user.has_access('recommendations','admin')
      cars = Recommendation.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Recommendation.where('approver_id = ?', current_user.id)
      @records = @records & cars
    end
  end




  def new
    @privileges = Privilege.find(:all)
    @table = params[:owner_type].present? ? "#{params[:owner_type]}Recommendation" : "Recommendation"
    @owner = Object.const_get(params[:owner_type])
      .find(params[:owner_id])
      .becomes(Object.const_get(params[:owner_type])) rescue nil
    @recommendation = Object.const_get(@table).new
    @fields = Recommendation.get_meta_fields('form')
  end


  def create
    @table = params[:owner_type].present? ? "#{params[:owner_type]}Recommendation" : "Recommendation"
    recommendation = Object.const_get(@table).create(params[:recommendation])
    redirect_to recommendation.becomes(Recommendation), flash: {success: "Recommendation created."}
  end



  def destroy
    recommendation=Recommendation.find(params[:id])
    recommendation.destroy
    redirect_to recommendations_path, flash: {danger: "Recommendation ##{params[:id]} deleted."}
  end



  def show
    @recommendation = Recommendation.find(params[:id])
    @type = get_recommendation_owner(@recommendation)
    @fields = Recommendation.get_meta_fields('show')
  end



  def edit
    @privileges = Privilege.find(:all)
    @recommendation = Recommendation.find(params[:id])
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable}
    @type = get_recommendation_owner(@recommendation)
    @users.keep_if{|u| u.has_access(@type, 'edit')}
    @headers = User.get_headers
    @fields = Recommendation.get_meta_fields('form')
  end



  def assign
    @owner = Recommendation.find(params[:id]).becomes(Recommendation)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = Recommendation.find(params[:id]).becomes(Recommendation)
    status = @owner.approver.present? ? "Pending Approval" : "Completed"
    render :partial => "/forms/workflow_forms/process", locals: {status: status}
  end

  def approve
    @owner = Recommendation.find(params[:id]).becomes(Recommendation)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def override_status
    @owner = Recommendation.find(params[:id]).becomes(Recommendation)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def update
    @owner = Recommendation.find(params[:id]).becomes(Recommendation)

    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Recommendation ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Recommendation Assigned')
    when 'Complete'
      if @owner.approver
        notify(@owner.approver,
          "Recommendation ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Recommendation Pending Approval')
      else
        @owner.complete_date = Time.now
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Recommendation ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Recommendation Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Recommendation ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Recommendation Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:recommendation][:status]}"
    end
    @owner.update_attributes(params[:recommendation])
    RecommendationTransaction.create(
      users_id: current_user.id,
      action:   params[:commit],
      owner_id: @owner.id,
      content:  transaction_content,
      stamp:    Time.now)
    @owner.save
    redirect_to recommendation_path(@owner)
  end




  def new_attachment
    @owner = Recommendation.find(params[:id]).becomes(Recommendation)
    @attachment = RecommendationAttachment.new
    render :partial => "shared/attachment_modal"
  end



  def print
    @deidentified = params[:deidentified]
    @recommendation = Recommendation.find(params[:id])
    html = render_to_string(:template => "/recommendations/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Recommendation_##{@recommendation.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end



  def reopen
    @recommendation = Recommendation.find(params[:id]).becomes(Recommendation)
    reopen_report(@recommendation)
  end


end
