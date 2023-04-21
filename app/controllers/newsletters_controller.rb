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

class NewslettersController < ApplicationController

  before_filter :login_required, :set_table

  def set_table
    @table = Object.const_get('Newsletter')
  end


  def index
    @title = "Newsletters"
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
    @newsletter = @table.new
    @distribution_list = DistributionList.all.map{|d| [d.id, d.title]}.to_h
    @action = "new"
  end


  def create
    @newsletter = @table.new(params[:newsletter])
    if @newsletter.save
      notify_on_object_creation(@newsletter)
      @newsletter.append_transaction('Create', current_user.id, "Newsletter #{@newsletter.title} Created")
      flash = {success: "Newsletter #{@newsletter.title} created"}
      redirect_path = newsletter_path(@newsletter)
    else
      flash = {warning: "Failed to create newsletter"}
      redirect_path = newsletters_path
    end

    redirect_to redirect_path, flash: flash
  end


  def edit
    @newsletter = @table.find(params[:id])
    @distribution_list = DistributionList.all.map{|d| [d.id, d.title]}.to_h
    @action = "edit"
  end


  def update
    @newsletter = @table.find(params[:id])
    newsletter_status = @newsletter.status

    if @newsletter.update_attributes(params[:newsletter])
      transaction_action = "Update"
      transaction_content = "Newsletter #{@newsletter.title} Updated"
      flash = {success: "Newsletter #{@newsletter.title} updated"}

      if params[:newsletter][:comments_attributes].present?
        params[:newsletter][:comments_attributes].each do |key, val|
          transaction_action = "Add Comment"
          transaction_content = val[:content] rescue nil
          flash = {success: "Comment Added to Newsletter #{@newsletter.title}"}
        end
      end

      if params[:commit] == 'Override Status'
        if newsletter_status != params[:newsletter][:status]
          if params[:newsletter][:status] == 'New'
            @newsletter.archive_date = nil
            @newsletter.publish_date = nil
            @newsletter.completions.each.map(&:destroy)
            @newsletter.save
          end
        end
        transaction_action = "Update Status"
        transaction_content = "Newsletter status updated from #{newsletter_status} to #{params[:newsletter][:status]}"
        flash = {success: "Newsletter #{@newsletter.title} status updated"}
      end

      @newsletter.append_transaction(transaction_action, current_user.id, transaction_content)
    else
      flash = {warning: "Failed to update newsletter"}
    end

    redirect_to newsletter_path(@newsletter), flash: flash
  end


  def show
    @newsletter = @table.find(params[:id])
    if (@newsletter.status == "Published" && (show_complete_button(@newsletter.id, current_user.id) == 1))
      flash[:notice] = "Please hit the Complete button to notify the creator of this Newsletter that you have acknowledged and completed your reading of this Newsletter."
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
    @newsletter = @table.find(params[:id])

    redirect_to newsletters_path, flash: {info: "#Newsletter #{@newsletter.id} #{@newsletter.title} has been deleted"}
    @newsletter.destroy
  end


  def publish
    @newsletter = @table.find(params[:id])
    @newsletter.status = "Published"
    @newsletter.publish_date = Time.now.to_date
    @newsletter.archive_date = nil
    @newsletter.save

    @newsletter.append_transaction('Publish', current_user.id, "Newsletter #{@newsletter.title} Published")
    notify_distributees(@newsletter)

    redirect_to newsletter_path(@newsletter)
  end


  def notify_distributees(newsletter)
    distro_ids = newsletter.distribution_list.split(",") rescue []
    distros = DistributionList.preload(:distribution_list_connections).where(id: distro_ids)

    if distros.present?
      user_ids = distros.map(&:get_user_ids).flatten

      user_ids.each do |id|
        notify(newsletter, notice: {
          users_id: id,
          content: "A new Newsletter with ID ##{newsletter.id} and title #{newsletter.title} has been published and distributed to you."},
          mailer: true, subject: "New Newsletter Published in ProSafeT")
      end
    end
  end


  def remind
    @newsletter = @table.find(params[:id])
    distro_ids = @newsletter.distribution_list.split(",") rescue []
    distros = DistributionList.preload(:distribution_list_connections).where(id: distro_ids)
    message = "No remaining users found. All users have read this Newsletter"

    if distros.present?
      user_ids = distros.map(&:get_user_ids).flatten
      completion_user_ids = Completion.where({owner_id: @newsletter.id, owner_type: @newsletter.class.name}).map(&:user_id) rescue []
      remaining_user_ids = user_ids - completion_user_ids

      if remaining_user_ids.present?
        remaining_user_ids.each do |id|
          notify(@newsletter, notice: {
            users_id: id,
            content: "This is a reminder to read Newsletter with ID ##{@newsletter.id} and title #{@newsletter.title} that has been distributed to you."},
            mailer: true, subject: "Reminder to Read Newsletter")
        end
        message = "Reminder sent to users with IDs (#{remaining_user_ids.join(", ")})"
      end
    else
      message = "No Distribution List found"
    end
    redirect_to newsletter_path(@newsletter), flash: {success: message}
  end


  def unpublish
    @newsletter = @table.find(params[:id])
    @newsletter.status = "New"
    @newsletter.archive_date = nil
    @newsletter.publish_date = nil
    @newsletter.completions.each.map(&:destroy)
    @newsletter.save

    @newsletter.append_transaction('UnPublish', current_user.id, "Newsletter #{@newsletter.title} UnPublished")

    redirect_to newsletter_path(@newsletter)
  end


  def archive
    @newsletter = @table.find(params[:id])
    @newsletter.status = "Archived"
    @newsletter.archive_date = Time.now.to_date
    @newsletter.save

    @newsletter.append_transaction('Archive', current_user.id, "Newsletter #{@newsletter.title} Archived")

    redirect_to newsletter_path(@newsletter)
  end


  def complete
    @newsletter = @table.find(params[:id])
    new_completion = Completion.create({owner_id: @newsletter.id, owner_type: 'Newsletter', complete_date: Time.now.to_date, user_id: current_user.id})
    completions = @newsletter.completions
    completions << new_completion
    @newsletter.completions = completions
    @newsletter.save

    redirect_to newsletter_path(@newsletter)
  end


  def new_attachment
    @owner=@table.find(params[:id])
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end

  def attachment_read
    attachment_id = params[:newsletter_attachment_id]
    @attachment = NewsletterAttachment.find(attachment_id)

    if @attachment.user_ids == nil
      @attachment.user_ids = Array.new
    end

    @newsletter = @table.find(params[:id])
    if params.keys.include? "read_receipt_#{attachment_id}"
      if params["read_receipt_#{attachment_id}"] == "on" && (!@attachment.user_ids.include? current_user.id)
        @attachment.user_ids << current_user.id
      else
        idx = @attachment.user_ids.index(current_user.id)
        deleted_user_id = @attachment.user_ids.delete_at(idx)
      end
    end
    @attachment.save
    redirect_to newsletter_path(@newsletter)
  end

  def new_newsletter_attachment
    @owner=@table.find(params[:id])
    @attachment=NewsletterAttachment.new
    render :partial=>"shared/newsletter_attachment_modal"
  end

end
