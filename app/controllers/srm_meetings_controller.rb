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

  def destroy
    @meeting = Meeting.find(params[:id])
    if @meeting.review_end.blank? || @meeting.meeting_end.blank?
      end_time = Time.now
    else
      end_time = @meeting.review_end > @meeting.meeting_end ? @meeting.review_end : @meeting.meeting_end
    end
    send_notices(
      @meeting.invitations,
      "Meeting ##{@meeting.get_id} has been cancelled.",
      true,
      "Cancellation of Meeting ##{@meeting.get_id}")

    #change the status of all linked SRAs
    @meeting.sras.each do |x|
      SraTransaction.create(
        :users_id => current_user.id,
        :action => "Remove from Meeting",
        :content => "Meeting Deleted",
        :owner_id =>x.id,
        :stamp => Time.now)
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
        SraTransaction.create(
          :users_id => current_user.id,
          :action => "Add to Meeting",
          :content => "Add to Meeting ##{@meeting.id}",
          :owner_id => sra.id,
          :stamp => Time.now)
        MeetingTransaction.create(
          :users_id => current_user.id,
          :action => "Added SRA",
          :content => "SRA ##{sra.get_id}",
          :owner_id => @meeting.id,
          :stamp => Time.now)
        sra.save
      end
    end
    if @meeting.save
      end_time = @meeting.review_end > @meeting.meeting_end ? @meeting.review_end : @meeting.meeting_end
      send_notices(
        @meeting.invitations,
        "You are invited to Meeting ##{@meeting.get_id}.  " + g_link(@meeting),
        true,
        "New Meeting Invitation")
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
    @users = User.find(:all) - [current_user]
    @users.keep_if{|u| !u.disable && u.has_access('meetings', 'index')}
    @sra_headers = Sra.get_meta_fields('index')
    @sras = Sra.where('meeting_id is ? and status = ?', nil, 'Open')
  end


  def show
    begin
      @meeting = Meeting.find(params[:id])
    rescue ActiveRecord::RecordNotFound
     redirect_to root_url
     return
    end
    @action = "show"
    @headers = User.invite_headers
    @users = @meeting.invitations.map{|x| x.user}
    @current_inv = @meeting.invitations.select{|x| x.user==current_user&&x.status=="Pending"}.first
    @sra_headers = Sra.get_meta_fields('index')
    @fields = SrmMeeting.get_meta_fields('show')
  end


  def index
    @records=SrmMeeting.find(:all)
    @headers=SrmMeeting.get_headers
    @title="Meetings"
  end


  def close
    @owner = Meeting.find(params[:id])
    render :partial => '/forms/workflow_forms/process', locals: {status: 'Closed'}
  end



  def update
    @owner = Meeting.find(params[:id])

    if !params[:sras].blank?
      params[:sras].each_pair do |index, value|
        sra = Sra.find(value)
        sra.meeting_id = @owner.id
        SraTransaction.create(
          :users_id => current_user.id,
          :action => "Add to Meeting",
          :content => "Add to Meeting ##{@owner.id}",
          :owner_id => sra.id,
          :stamp=>Time.now)
        MeetingTransaction.create(
          :users_id => current_user.id,
          :action => "Added SRA",
          :content => "SRA ##{sra.get_id}",
          :owner_id => @owner.id,
          :stamp => Time.now)
        sra.save
      end
    end

    case params[:commit]
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:meeting][:status]}"
    when 'Close'
      send_notices(
        @owner.invitations,
        "Meeting ##{@owner.get_id} has been Closed." + g_link(@owner),
        true,
        "Meeting ##{@owner.get_id} Closed")
    end

    if params[:invitations].present?
      params[:invitations].each_pair do |index,val|
        inv = @owner.invitations.where("users_id=?",val)
        if inv.blank?
          new_inv = Invitation.new()
          new_inv.users_id = val
          new_inv.meeting = @owner
          new_inv.save
          send_notice(new_inv,
            "You are invited to Meeting ##{@owner.get_id}.  " + g_link(@owner),
            true, "New Meeting Invitation")
        end
      end
    end
    if params[:cancellation].present?
      params[:cancellation].each_pair do |index,val|
        inv = @owner.invitations.where("users_id=?",val)
        if inv.present?
          send_notice(inv.first, "You are no longer invited to Meeting ##{@owner.id}.", true, "Removed from Meeting")
          inv.first.destroy
        end
      end
    end

    @owner.update_attributes(params[:meeting])
    MeetingTransaction.create(
      users_id: current_user.id,
      action:   params[:commit],
      owner_id: @owner.id,
      content:  transaction_content,
      stamp:    Time.now)
    @owner.save
    redirect_to srm_meeting_path(@owner)
  end


  def edit
    @meeting = Meeting.find(params[:id])
    @action = "edit"
    @headers = User.invite_headers
    @users = User.find(:all) - [@meeting.host.user]
    @users.keep_if{|u| !u.disable && u.has_access("meetings", "index")}
    @timezones = Meeting.get_timezones
    @sra_headers = Sra.get_meta_fields('index')
    @sras = @meeting.sras + Sra.where("status = 'Open'")
  end


  def send_notices(participations, message, mailer, subject)
    participations.each do |p|
      send_notice(p, message, true, subject)
    end
  end


  def send_notice(p, message, mailer, subject=nil)
    notify(p.user, message, mailer, subject)
  end


  def reopen
    @meeting = Meeting.find(params[:id]).becomes(Meeting)
    @meeting.status = "Open"
    @meeting.save
    MeetingTransaction.create(
      :users_id => current_user.id,
      :action => "Reopen",
      :owner_id => @meeting.id,
      :stamp => Time.now)
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
        "You have a new internal message sent from Meeting. " + g_link(message),
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
        SraTransaction.create(
          :users_id => current_user.id,
          :action => "Add to Meeting",
          :content => "Add to Meeting ##{meeting.id}",
          :owner_id => sra.id,
          :stamp => Time.now)
        MeetingTransaction.create(
          :users_id => current_user.id,
          :action => "Added SRA",
          :content => "SRA ##{sra.get_id}",
          :owner_id => meeting.id,
          :stamp => Time.now)
        sra.save
      end
    end
    redirect_to srm_meeting_path(meeting)
  end


  def new_attachment
    @owner=Meeting.find(params[:id]).becomes(Meeting)
    @attachment=MeetingAttachment.new
    render :partial=>"shared/attachment_modal"
  end


  def print
    @meeting = Meeting.find(params[:id])
    html = render_to_string(:template=>"/srm_meetings/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    send_data pdf.to_pdf, :filename => "Meeting_##{@meeting.get_id}.pdf"
  end
end
