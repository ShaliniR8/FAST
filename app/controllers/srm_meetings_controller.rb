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

class SrmMeetingsController < ApplicationController
  before_filter :set_table_name,:login_required
  before_filter :define_owner, only: [:interpret]

  def define_owner
    @class = Object.const_get('Meeting')
    @owner = Meeting.find(params[:id]).becomes(Meeting)
  end

  def destroy
    @meeting = Meeting.find(params[:id])
    if @meeting.review_end.blank? || @meeting.meeting_end.blank?
      end_time = Time.now
    else
      end_time = @meeting.review_end > @meeting.meeting_end ? @meeting.review_end : @meeting.meeting_end
    end

    @meeting.invitations.each do |inv|
      notify(@meeting, notice: {
        users_id: inv.users_id,
        content: "Meeting ##{@meeting.id} has been canceled."},
        mailer: true, subject: "Meeting Canceled")
    end

    #change the status of all linked SRAs
    @meeting.sras.each do |x|
      Transaction.build_for(
        x,
        'Remove from Meeting',
        current_user.id,
        'Meeting Deleted'
      )
      x.status = "Open"
      x.meeting_id = nil
      x.save
    end

    @meeting.destroy
    redirect_to srm_meetings_path, flash: {danger: "Meeting ##{params[:id]} deleted."}
  end

  def set_table_name
    @table_name = "srm_meetings"
  end


  def create
    @meeting = SrmMeeting.create(params[:srm_meeting])
    if !params[:sras].blank?
      params[:sras].each_pair do |index, value|
        sra = Sra.find(value)
        sra.meeting_id = @meeting.id
        Transaction.build_for(
          sra,
          'Add to Meeting',
          current_user.id,
          "Add to Meeting ##{@meeting.id}"
        )
        Transaction.build_for(
          @meeting,
          'Added SRA',
          current_user.id,
          "SRA ##{sra.get_id}"
        )
        sra.save
      end
    end
    if @meeting.save
      @meeting.set_datetimez
      @meeting.save
      end_time = @meeting.review_end > @meeting.meeting_end ? @meeting.review_end : @meeting.meeting_end
      @meeting.invitations.each do |inv|
        notify(@meeting, notice: {
          users_id: inv.users_id,
          content: "You are invited to Meeting ##{@meeting.id}."},
          mailer: true, subject: "New Meeting Invitation")
      end
      redirect_to srm_meeting_path(@meeting), flash: {success: "Meeting created."}
    else
      redirect_to new_srm_meeting_path(:type=>params[:type])
    end
  end


  def new
    @privileges = Privilege.find(:all)
    @meeting = SrmMeeting.new
    @action = "new"
    @timezones = Meeting.get_timezones
    @headers = User.invite_headers
    # @users = User.find(:all) - [current_user]
    # @users.keep_if{|u| !u.disable && u.has_access('meetings', 'index')}

    # rules = AccessControl.preload(:privileges).where(entry: 'meetings', action: ['show'])
    rules = AccessControl.preload(:privileges).where(entry: 'srm_meetings', action: ['show'])
    privileges = rules.map(&:privileges).flatten
    users = privileges.map(&:users).flatten.uniq
    @available_participants = User.preload(:invitations).where(id: users.map(&:id)).active

    @sra_headers = Sra.get_meta_fields('index')
    @sras = Sra.where('meeting_id is ?', nil)
  end


  def show
    begin
      @meeting = Meeting.find(params[:id])
    rescue ActiveRecord::RecordNotFound
     redirect_to root_url
     return
    end
    @action = "show"
    @has_status = true
    @headers = User.invite_headers
    @available_participants = @meeting.invitations.map{|x| x.user}
    @current_inv = @meeting.invitations.select{|x| x.user==current_user&&x.status=="Pending"}.first
    @sra_headers = Sra.get_meta_fields('index')
    @fields = SrmMeeting.get_meta_fields('show')
  end


  def index
    # @records=SrmMeeting.includes(:invitations, :host)
    # unless current_user.has_access('srm_meetings', 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true)
    #   @records = @records.where('(participations.users_id = ? AND participations.status in (?)) OR hosts_meetings.users_id = ?',
    #     current_user.id, ['Pending', 'Accepted'], current_user.id)
    # end
    @table = Object.const_get("SrmMeeting")
    @headers=SrmMeeting.get_headers
    @title="Meetings"
    handle_search
  end


  def close
    @owner = Meeting.find(params[:id])
    render :partial => '/forms/workflow_forms/process', locals: {status: 'Closed'}
  end


  def override_status
    @owner = SrmMeeting.find(params[:id]).becomes(SrmMeeting)
    render :partial => '/forms/workflow_forms/override_status'
  end

  def save_agenda
    @meeting = SrmMeeting.find(params[:id])
    @sra_headers = Sra.get_meta_fields('index')
    update_hash = Hash.new
    deleted_agenda_ids = []
    params.each do |key, value|
      if ["authenticity_token", "event_id", "user_id"].exclude?(key)
        key_parts = key.split('_')
        if key_parts.length == 2
          agenda_id = key_parts[1].to_i rescue 0
          if agenda_id > 0
            if !update_hash.key?(agenda_id)
              update_hash[agenda_id] = Hash.new
            end
            if key_parts[0] == 'destroy'
              if eval(value) == true
                deleted_agenda_ids << agenda_id
              end
            else
              update_hash[agenda_id][key_parts[0].to_sym] = value
            end
            if key_parts[0] == 'discussion'
              if value == "true"
                update_hash[agenda_id][key_parts[0].to_sym] = 1
              else
                update_hash[agenda_id][key_parts[0].to_sym] = 0
              end
            end
          end
        end
      end
    end
    deleted_agenda_ids.each do |a_id|
      ag = SrmAgenda.find(a_id)
      if ag.present?
        update_hash.delete(a_id)
        ag.destroy
      end
    end

    update_hash.each do |k, v|
      ag = SrmAgenda.find(k) rescue nil
      if ag.nil?
        v[:user_id] = params[:user_id]
        v[:event_id] = params[:event_id]
        v[:owner_id] = params[:id]
        v[:type] = "SrmAgenda"
        SrmAgenda.create(v)
      else
        ag.update_attributes(v)
      end
    end
    @meeting = SrmMeeting.find(params[:id])
    @sras = @meeting.sras.sort_by{|x| x.id}

    Transaction.build_for(
      @meeting,
      "Save SrmAgenda",
      current_user.id,
      "SRA ##{params[:event_id]}"
    )

    respond_to do |format|
      format.js
    end

  end
  

  def update
    @owner = Meeting.find(params[:id])

    if !params[:sras].blank?
      params[:sras].each_pair do |index, value|
        sra = Sra.find(value)
        sra.meeting_id = @owner.id
        Transaction.build_for(
          sra,
          'Add to Meeting',
          current_user.id,
          "Add to Meeting ##{@owner.id}"
        )
        Transaction.build_for(
          @owner,
          'Added SRA',
          current_user.id,
          "SRA ##{sra.get_id}"
        )
        sra.save
      end
    end

    transaction_content = params[:srm_meeting][:final_comment] rescue nil
    if transaction_content.nil?
      if params[:meeting].present?
        if params[:meeting][:comments_attributes].present?
          params[:meeting][:comments_attributes].each do |key, val|
            transaction_content = val[:content] rescue nil
          end
        end
      end
    end

    case params[:commit]
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:srm_meeting][:status]}"
    when 'Close'
      @owner.invitations.each do |inv|
        notify(@owner, notice: {
          users_id: inv.users_id,
          content: "Meeting ##{@owner.id} has been closed."},
          mailer: true, subject: "Meeting Closed")
      end
      status = 'Closed'
    when 'Save Agenda'
      transaction_content = "SRA ##{params[:sra_id]}"
    end

    if params[:invitations].present?
      params[:invitations].each_pair do |index,val|
        inv = @owner.invitations.where("users_id=?",val)
        if inv.blank?
          new_inv = Invitation.new()
          new_inv.users_id = val
          new_inv.meeting = @owner
          new_inv.save
          notify(@owner, notice: {
            users_id: new_inv.users_id,
            content: "You are invited to Meeting ##{@owner.get_id}."},
            mailer: true, subject: "New Meeting Invitation")
        end
      end
    end
    if params[:cancellation].present?
      params[:cancellation].each_pair do |index,val|
        inv = @owner.invitations.where("users_id = ?", val).first
        if inv.present?
          notify(@owner, notice: {
            users_id: inv.users_id,
            content: "You are no longer invited to Meeting ##{@owner.id}."},
            mailer: true, subject: 'Removed from Meeting')
          inv.destroy
        end
      end
    end
    @owner.update_attributes(params[:srm_meeting])
    Transaction.build_for(
      @owner,
      params[:commit],
      current_user.id,
      transaction_content
    )
    if status.present?
      @owner.status = status
      @owner.save
    end
    @owner.set_datetimez
    @owner.save
    redirect_to srm_meeting_path(@owner)
  end


  def edit
    @has_status = true
    @meeting = Meeting.find(params[:id])
    @action = "edit"
    @headers = User.invite_headers

    rules = AccessControl.preload(:privileges).where(entry: 'srm_meetings', action: ['show'])
    privileges = rules.map(&:privileges).flatten
    users = privileges.map(&:users).flatten.uniq
    @available_participants = User.preload(:invitations).where(id: users.map(&:id)).active


    @timezones = Meeting.get_timezones
    @sra_headers = Sra.get_meta_fields('index')
    @sras = @meeting.sras + Sra.where('meeting_id is ?', nil)
  end


  def reopen
    @meeting = Meeting.find(params[:id]).becomes(Meeting)
    @meeting.status = "Open"
    @meeting.save
    Transaction.build_for(
      @meeting,
      'Reopen',
      current_user.id
    )
    redirect_to meeting_path(@meeting)
  end


  def message
    @meeting=Meeting.find(params[:id])
    @users=@meeting.invitations.map{|x| x.user}
    @options=Meeting.getMessageOptions
    @headers=User.invite_headers
  end

  def send_message
    @meeting = Meeting.find(params[:id])
    invitations = @meeting.invitations
    users = []
    if !params[:send_to].blank?
      if params[:send_to] == "All"
        users += invitations.map{|x| x.user}
      elsif params[:send_to] == "Par"
        users += invitations.select{|x| x.status != "Rejected"}.map{|x| x.user}
      elsif params[:send_to] == "Rej"
        users += invitations.select{|x| x.status == "Rejected"}.map{|x| x.user}
      elsif params[:send_to] == "Acp"
        users += invitations.select{|x| x.status == "Accepted"}.map{|x| x.user}
      elsif params[:send_to] == "Pen"
        users += invitations.select{|x| x.status == "Pending"}.map{|x| x.user}
      else
      end
    elsif !params[:message_to].blank?
      users += User.find(params[:message_to].values)
      users.keep_if{|u| !u.disable}
    else
    end
    users.push(@meeting.host.user)
    users.uniq!{|x| x.id}

    message = Message.create(
      :subject => params[:subject],
      :content => params[:message],
      :link => srm_meeting_path(@meeting),
      :link_type => 'Meeting',
      :link_id => @meeting.id,
      :time => Time.now)
    sent_from = SendFrom.create(
      :messages_id => message.id,
      :users_id => current_user.id)
    users.each do |user|
      SendTo.create(
        :messages_id => message.id,
        :users_id => user.id)
      notify(User.find(user),
        "You have a new internal message sent from Meeting ##{@meeting.id}. #{g_link(message)}",
        true, 'New Internal Meeting Message')
    end
    redirect_to srm_meeting_path(@meeting)
  end


  def add_sras
    @meeting = Meeting.find(params[:id])
    @sras = Sra.where('meeting_id is ? and status != ?', nil, 'Completed')
    @sra_headers = Sra.get_meta_fields('index')
    render :partial => "add_sras"
  end


  def sras
    meeting = Meeting.find(params[:id])
    if params[:sras].present? 
      params[:sras].each do |sid|
        sra = Sra.find(sid)
        sra.meeting_id = meeting.id
        Transaction.build_for(
          sra,
          'Add to Meeting',
          current_user.id,
          "Add to Meeting ##{meeting.id}"
        )
        Transaction.build_for(
          meeting,
          'Added SRA',
          current_user.id,
          "SRA ##{sra.get_id}"
        )
        sra.save
      end
    end
    redirect_to srm_meeting_path(meeting)
  end


  def new_attachment
    @owner=Meeting.find(params[:id]).becomes(Meeting)
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end


end
