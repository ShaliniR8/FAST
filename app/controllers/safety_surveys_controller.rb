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

class SafetySurveysController < ApplicationController

  before_filter :login_required, :set_table

  def set_table
    @table = Object.const_get('SafetySurvey')
  end


  def index
    @title = "Safety Surveys"
    @headers = @table.get_meta_fields('index')
    @records = @table.find(:all)
    if !current_user.has_access(@table.rule_name, 'admin', admin: CONFIG::GENERAL[:global_admin_default])
      recs = []
      @records.each do |r|
        distro_list = DistributionList.preload(:distribution_list_connections).where(id: r.distribution_list.split(',')).map{|d| d.get_user_ids}.flatten rescue []
        recs << r if ((r.status != 'New' && distro_list.include?(current_user.id)) || r.user_id == current_user.id)
      end
      @records = recs
    end
    render 'index'
  end


  def new
    @survey = @table.new
    @distribution_list = DistributionList.all.map{|d| [d.id, d.title]}.to_h
    @action = "new"
  end


  def create
    @survey = @table.new(params[:safety_survey])
    if @survey.save
      notify_on_object_creation(@survey)
      @survey.append_transaction('Create', current_user.id, "Safety Survey #{@survey.title} Created")
      flash = {success: "Safety Survey #{@survey.title} created"}
      redirect_path = safety_survey_path(@survey)
    else
      flash = {warning: "Failed to create safety survey"}
      redirect_path = safety_surveys_path
    end

    redirect_to redirect_path, flash: flash
  end


  def edit
    @survey = @table.find(params[:id])
    @distribution_list = DistributionList.all.map{|d| [d.id, d.title]}.to_h
    @action = "edit"
  end


  def update
    @survey = @table.find(params[:id])
    survey_status = @survey.status

    if @survey.update_attributes(params[:safety_survey])
      transaction_action = "Update"
      transaction_content = "Safety Survey #{@survey.title} Updated"
      flash = {success: "Safety Survey #{@survey.title} updated"}

      if params[:safety_survey][:comments_attributes].present?
        params[:safety_survey][:comments_attributes].each do |key, val|
          transaction_action = "Add Comment"
          transaction_content = val[:content] rescue nil
          flash = {success: "Comment Added to Safety Survey #{@survey.title}"}
        end
      end

      if params[:commit] == 'Override Status'
        if survey_status != params[:safety_survey][:status]
          if params[:safety_survey][:status] == 'New'
            @survey.archive_date = nil
            @survey.publish_date = nil
            @survey.completions.each.map(&:destroy)
            @survey.save
          end
        end
        transaction_action = "Update Status"
        transaction_content = "Safety Survey status updated from #{survey_status} to #{params[:safety_survey][:status]}"
        flash = {success: "Safety Survey #{@survey.title} status updated"}
      end

      @survey.append_transaction(transaction_action, current_user.id, transaction_content)
    else
      flash = {warning: "Failed to update safety survey"}
    end

    redirect_to safety_survey_path(@survey), flash: flash
  end


  def show
    @survey = @table.find(params[:id])
    if (current_user.has_access(Object.const_get('SafetySurvey').rule_name, "edit", admin: CONFIG::GENERAL[:global_admin_default]) && @survey.my_action(current_user.id) == 'Not Completed')
      flash[:notice] = "Please hit the Complete button to notify the creator that you have completed the Safety Survey."
    end
  end


  def comment
    @owner = @table.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end


  def override_status
    @owner = @table.find(params[:id])
    render :partial => '/forms/workflow_forms/override_status'
  end


  def destroy
    @survey = @table.find(params[:id])

    redirect_to safety_surveys_path, flash: {info: "#Safety Survey #{@survey.id} #{@survey.title} has been deleted"}
    @survey.destroy
  end


  def get_user_list
    @users = User.where(id: params[:list].split(',')) rescue []
    render :partial => '/safety_surveys/user_list'
  end


  def get_responses_distribution
    @owner = @table.find(params[:id])
    checklist_ids = Completion.preload(:checklist).where({owner_id: params[:id], owner_type: 'SafetySurvey'}).keep_if{|c| c.checklist.present?}.map{|c| c.checklist.id}.flatten rescue []
    user_ids = Completion.where({owner_id: params[:id], owner_type: 'SafetySurvey'}).keep_if{|c| c.checklist.present?}.map{|c| c.user_id} rescue []
    checklists = Checklist.preload(:checklist_rows => :checklist_cells).where(id: checklist_ids)
    users = User.where(id: user_ids).map{|u| [u.id, u.full_name]}.to_h

    rows = []
    checklists.each do |c|
      rows << c.checklist_rows[params[:rowind].to_i]
    end

    @user_responses = Hash.new
    @grouped_responses = Hash.new

    rows.each_with_index do |r, ind|
      r.checklist_cells.each do |c|
        if c.checklist_header_item_id == params[:header].to_i
          val = c.value.nil? ? "" : c.value
          @user_responses[users[user_ids[ind]]] = val
          if !(c.data_type == "text" && c.checklist_header_item.data_type == "text")
            if @grouped_responses[val].present?
              grouped_users = @grouped_responses[val]
              @grouped_responses[val] = "#{grouped_users},#{user_ids[ind]}"
            else
              @grouped_responses[val] = user_ids[ind].to_s
            end
          end
        end
      end
    end

    render :partial => '/safety_surveys/responses_distribution'
  end


  def publish
    @survey = @table.find(params[:id])
    publish_message = "Safety Survey #{@survey.title} has been published"
    if @survey.checklist.present?
      @survey.status = "Published"
      @survey.publish_date = Time.now.to_date
      @survey.archive_date = nil
      @survey.save

      @survey.append_transaction('Publish', current_user.id, "Safety Survey #{@survey.title} Published")
      notify_distributees_and_create_checklist(@survey)
    else
      publish_message = "Safety Survey #{@survey.title} could not be published because no checklist was added. Please add a checklist to publish the survey so that users can respond"
    end

    redirect_to safety_survey_path(@survey), flash: {success: publish_message}
  end


  def notify_distributees_and_create_checklist(survey)
    distro_ids = survey.distribution_list.split(",") rescue []
    distros = DistributionList.preload(:distribution_list_connections).where(id: distro_ids)

    if distros.present?
      user_ids = distros.map(&:get_user_ids).flatten

      user_ids.each do |id|
        notify(survey, notice: {
          users_id: id,
          content: "A new Safety Survey with ID ##{survey.id} and title #{survey.title} has been published and distributed to you."},
          mailer: true, subject: "New Safety Survey Published in ProSafeT")
      end

      call_rake 'create_survey_checklists',
        survey_id: survey.id,
        users: user_ids
    end
  end


  def remind
    @survey = @table.find(params[:id])
    distro_ids = @survey.distribution_list.split(",") rescue []
    distros = DistributionList.preload(:distribution_list_connections).where(id: distro_ids)
    message = "No remaining users found. All users have completed this Safety Survey"

    if distros.present?
      user_ids = distros.map(&:get_user_ids).flatten
      completion_user_ids = Completion.where({owner_id: @survey.id, owner_type: @survey.class.name}).keep_if{|c| c.complete_date.present?}.map(&:user_id) rescue []
      remaining_user_ids = user_ids - completion_user_ids

      if remaining_user_ids.present?
        remaining_user_ids.each do |id|
          notify(@survey, notice: {
            users_id: id,
            content: "This is a reminder to complete Safety Survey with ID ##{@survey.id} and title #{@survey.title} that has been distributed to you."},
            mailer: true, subject: "Reminder to Read Safety Survey")
        end
        message = "Reminder sent to users with IDs (#{remaining_user_ids.join(", ")})"
      end
    else
      message = "No Distribution List found"
    end
    redirect_to safety_survey_path(@survey), flash: {success: message}
  end


  def unpublish
    @survey = @table.find(params[:id])
    @survey.status = "New"
    @survey.archive_date = nil
    @survey.publish_date = nil
    @survey.completions.each.map(&:destroy)
    @survey.save

    @survey.append_transaction('UnPublish', current_user.id, "Safety Survey #{@survey.title} UnPublished")

    redirect_to safety_survey_path(@survey)
  end


  def archive
    @survey = @table.find(params[:id])
    @survey.status = "Archived"
    @survey.archive_date = Time.now.to_date
    @survey.save

    @survey.append_transaction('Archive', current_user.id, "Safety Survey #{@survey.title} Archived")

    redirect_to safety_survey_path(@survey)
  end


  def complete
    @survey = @table.find(params[:id])
    completion = Completion.where({owner_id: @survey.id, owner_type: "SafetySurvey", user_id: current_user.id}).first
    if completion.present?
      completion.complete_date = Time.now.to_date
      completion.save
    end

    redirect_to safety_survey_path(@survey)
  end


  def new_attachment
    @owner=@table.find(params[:id])
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end

end
