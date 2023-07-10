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
class SmsMeetingsController < ApplicationController
  before_filter :set_table_name,:login_required

  def destroy
    @meeting=Meeting.find(params[:id])
    if @meeting.review_end.blank? ||@meeting.meeting_end.blank?
      end_time=Time.now
    else
      end_time=@meeting.review_end > @meeting.meeting_end ?   @meeting.review_end  : @meeting.meeting_end
    end
    #send_notices(@meeting.invitations,end_time,"A meeting has been cancelled.")
    send_notices(
      @meeting.invitations,
      "Meeting ##{@meeting.get_id} has been cancelled.",
      true,
      "Meeting ##{@meeting.get_id} Canceled")

    @meeting.invitations.each do |p|
      notify(@meeting,
        notice: {
          users_id: p.user.id,
          content: "Cancellation of Invitation from Meeting ##{@meeting.get_id}" + g_link(@meeting)},
        mailer: true,
        subject: "Cancellation of Meeting ##{@meeting.get_id}")
    end
      notify(@meeting,
        notice: {
          users_id: @meeting.host.user.id,
          content: "Cancellation of Invitation from Meeting ##{@meeting.get_id}" + g_link(@meeting)},
        mailer: true,
        subject: "Cancellation of Meeting ##{@meeting.get_id}")
    @meeting.packages.each do |x|
      Transaction.build_for(
        x,
        'Open',
        current_user.id,
        'Meeting Deleted'
      )
      x.status = "Open"
      x.meeting_id = nil
      x.save
    end


    redirect_to sms_meetings_path(:type=>@meeting.type), flash: {danger: "Meeting ##{params[:id]} deleted."}
    @meeting.destroy
    #redirect_to meetings_path

  end

  def set_table_name
    #Rails.logger.debug "#{controller_name}  #{action_name} set table!"
    @table_name="sms_meetings"
  end
  def create
    @meeting=Object.const_get(params[:type]).new(params[:sms_meeting])


    if !params[:packages].blank?
      @meeting.save
      params[:packages].each_pair do |index, value|
        package = Package.find(value)
        package.meeting_id=@meeting.id
        package.status = "Awaiting Review"
        #SraTransaction.create(:users_id=>current_user.id,:action=>"Under Review",:content=>"Add to Meeting ##{@meeting.id}", :owner_id=>report.id,:stamp=>Time.now)
        #MeetingTransaction.create(:users_id=>current_user.id, :action=>"Added SRA ##{sra.get_id}",:content=>"SRA ##{sra.get_id}", :owner_id => @meeting.id, :stamp=>Time.now)
        package.save
      end
    end


    if @meeting.save
      end_time=@meeting.review_end>@meeting.meeting_end ?   @meeting.review_end  : @meeting.meeting_end
      #send_notices(@meeting.invitations,end_time,"You are invited to a meeting.  "+generate_link_to("Click to view",@meeting))
      send_notices(
        @meeting.invitations,
        "You are invited to meeting ##{@meeting.get_id}.  " + g_link(@meeting),
        true,
        "You are invited to meeting ##{@meeting.get_id}")

      @meeting.invitations.each do |p|
        notify(@meeting,
          notice: {
            users_id: p.user.id,
            content: "New Meeting ##{@meeting.get_id} Notification" + g_link(@meeting)},
          mailer: true,
          subject: "New Meeting ##{@meeting.get_id} Notification")
      end
        notify(@meeting,
          notice: {
            users_id: @meeting.host.user.id,
            content: "New Meeting ##{@meeting.get_id} Notification" + g_link(@meeting)},
          mailer: true,
          subject: "New Meeting ##{@meeting.get_id} Notification")
      redirect_to sms_meeting_path(@meeting)
    else
      redirect_to new_sms_meeting_path(:type=>params[:type])
    end
  end


  def new
    @meeting = Object.const_get(params[:type]).new
    @action = "new"
    @timezones = Meeting.get_timezones
    @headers = User.invite_headers
    # rules = AccessControl.preload(:privileges).where(entry: 'meetings', action: ['show'])
    rules = AccessControl.preload(:privileges).where(entry: 'sms_meetings', action: ['show'])
    privileges = rules.map(&:privileges).flatten
    users = privileges.map(&:users).flatten.uniq
    @available_participants = User.preload(:invitations).where(id: users.map(&:id)).active

    @package_headers = Package.get_headers
    @package_type = ''
    if params[:type] == 'JobMeeting'
      @package_type = 'JobAidPackage'
    elsif params[:type] == 'VpMeeting'
      @package_type = 'VpImPackage'
    elsif params[:type] == 'FrameworkMeeting'
      @package_type = 'FrameworkImPackage'
    end
    @packages = Package.where('meeting_id is ? and status = ? and type = ?',nil, 'Open', @package_type)
  end


  def show
    begin
      @meeting=Meeting.find(params[:id])
    rescue ActiveRecord::RecordNotFound
     redirect_to root_url
     return
    end
    @title = ''
    if @meeting.type == "VpMeeting"
      @title = 'VP/Part 5'
    elsif @meeting.type == "JobMeeting"
      @title = "Job Aid"
    elsif @meeting.type == "FramworkMeeting"
      @title = "Framework IM"
    end
    @action="show"
    @headers=User.invite_headers

    @available_participants = @meeting.invitations.map{|x| x.user}

    @current_inv=@meeting.invitations.select{|x| x.user==current_user&&x.status=="Pending"}.first
    @package_type=@meeting.class.package_type
    @package_headers=Package.get_headers
    @fields = Meeting.get_meta_fields('show')
  end


  def index
    @records=Object.const_get(params[:type]).includes(:invitations, :host)
    unless current_user.global_admin?
      @records = @records.where('(participations.users_id = ? AND participations.status in (?)) OR hosts_meetings.users_id = ?',
        current_user.id, ['Pending', 'Accepted'], current_user.id)
    end
    @headers=SmsMeeting.get_headers
    @type = ''
    if params[:type] == "VpMeeting"
      @type = 'VP/Part 5'
    elsif params[:type] == "JobMeeting"
      @type = 'Job Aid'
    elsif params[:type] == "FramworkMeeting"
      @type = 'Framework IM'
    end
    @title="#{@type} Meetings"
  end


  def close
    meeting=Meeting.find(params[:id])
    Transaction.build_for(
      meeting,
      'Close',
      current_user.id
    )
    meeting.status="Closed"
    meeting.closing_date = Time.now
    if meeting.save
      redirect_to sms_meeting_path(meeting)
    end
  end


  def update
    @meeting = Meeting.find(params[:id])
    @meeting.update_attributes(params[:sms_meeting])

    if !params[:packages].blank?
      @meeting.save
      params[:packages].each_pair do |index, value|
        package = Package.find(value)
        package.meeting_id=@meeting.id
        package.status = "Awaiting Review"
        package.save
      end
    end


    if params[:invitations].present?
      params[:invitations].each_pair do |index,val|
        inv=@meeting.invitations.where("users_id=?",val)
        if inv.blank?
          new_inv=Invitation.new()
          new_inv.users_id=val
          new_inv.meeting=@meeting
          new_inv.save
          send_notice(
            new_inv,
            "You are invited to a meeting.  " + g_link(@meeting),
            true,
            "You are invited to a meeting")
          notify(@meeting,
            notice: {
              users_id: new_inv.user.id,
              content: "New Meeting ##{@meeting.get_id} Notification" + g_link(@meeting)},
            mailer: true,
            subject: "New Meeting ##{@meeting.get_id} Notification")
        end
      end
    end


    if params[:cancellation].present?
      params[:cancellation].each_pair do |index,val|
        inv=@meeting.invitations.where("users_id=?",val)
        if inv.present?
          Rails.logger.debug("Deleting")
          notify(@meeting,
            notice: {
              users_id: inv.first.user.id,
              content: "Cancellation of Meeting ##{@meeting.get_id}" + g_link(@meeting)},
            mailer: true,
            subject: "Cancellation of Meeting ##{@meeting.get_id}")
          inv.first.destroy
        end
      end
    end

    if @meeting.previous_changes.present?
      Transaction.build_for(
        @meeting,
        'Edit',
        current_user.id
      )
    end
    redirect_to sms_meeting_path(@meeting), flash: {success: "Meeting updated."}
  end

  def edit
    @meeting=Meeting.find(params[:id])
    @action="edit"
    @headers=User.invite_headers
    @users=User.find(:all) - [@meeting.host.user]
    @users.keep_if{|u| !u.disable && u.has_access("meetings", "index")}
    @timezones=Meeting.get_timezones
    @package_headers = Package.get_headers
    @packages = @meeting.packages+ Package.where("status = 'Open'")
  end

  # def send_notices(participations,expire,message)
  #   participations.each do |p|
  #     send_notice(p,expire,message)
  #   end
  # end
  # def send_notice(p,expire,message)
  #   notify(p.user,expire,message)
  # end
  def send_notices(participations, message, mailer, subject)
    participations.each do |p|
      send_notice(
        p,
        message,
        mailer,
        subject)
    end
  end
  def send_notice(participant, message, mailer, subject)
    notify(participant,
    notice: {
      users_id: participant.user.id,
      content: message},
    mailer: mailer,
    subject: subject)
    #notify(p.user,expire,message)
  end


  def message
    @meeting=Meeting.find(params[:id])
    @users=@meeting.invitations.map{|x| x.user}
    @options=Meeting.getMessageOptions
    @headers=User.invite_headers
  end

  def send_message
    @meeting=Meeting.find(params[:id])
    invitations=@meeting.invitations
    users=[]
    if !params[:send_to].blank?
      if params[:send_to]=="All"
        users+=invitations.map{|x| x.user}
      elsif params[:send_to]=="Par"
        users+=invitations.select{|x| x.status!="Rejected"}.map{|x| x.user}
      elsif params[:send_to]=="Rej"
        users+=invitations.select{|x| x.status=="Rejected"}.map{|x| x.user}
      elsif params[:send_to]=="Acp"
        users+=invitations.select{|x| x.status!="Accepted"}.map{|x| x.user}
      elsif params[:send_to]=="Pen"
        users+=invitations.select{|x| x.status=="Pending"}.map{|x| x.user}
      else
      end
    elsif !params[:message_to].blank?
      users+=User.find(params[:message_to].values)
      users.keep_if{|u| !u.disable}
    else
    end
    users.push(@meeting.host.user)
    users.uniq!{|x| x.id}
    file_path=""
    if !params[:att].blank?
      uploaded_io = params[:att]
      file_path=Rails.root.join('public', 'uploads',"message_attachment", SecureRandom.uuid.to_s+ "_"+uploaded_io.original_filename)
      Rails.logger.debug(file_path)
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_io.read)
      end
    end
    host_header="From "+@meeting.host.user.full_name+":<br>"
    users.each do |u|
      notify(@meeting,
        notice: {
          users_id: u.id,
          content: "You have a message sent from Meeting ##{@meeting.get_id}" + g_link(@meeting)},
        mailer: true,
        subject: "Message Received from Meeting ##{@meeting.get_id}")
    end
    redirect_to send_success_sms_meetings_path
  end

  def add_packages
    @meeting=Meeting.find(params[:id])
    @packages=Object.const_get(params[:type]).where('status=?','Open')
    @package_headers=Package.get_headers
    render :partial=>"add_packages"
  end

  def packages
    meeting=Meeting.find(params[:id])
    if params[:packages].present?
      params[:packages].each do |pid|
        package=Package.find(pid)
        package.meeting_id=meeting.id
        package.status="Awaiting Review"
        package.save
      end
    end
    redirect_to sms_meeting_path(meeting)
  end


  def print
    @meeting = Meeting.find(params[:id])
    html = render_to_string(:template=>"/sms_meetings/print.html.erb")
    pdf_options = {}
    if CONFIG::GENERAL[:has_pdf_logo]
      pdf_options[:header_html] =  "app/views/pdfs/#{AIRLINE_CODE}/print_header.html"
    end
    if CONFIG::GENERAL[:has_pdf_footer]
      pdf_options.merge!({
        footer_html:  "app/views/pdfs/#{AIRLINE_CODE}/print_footer.html",
        footer_spacing:  3,
      })
    end
    pdf = PDFKit.new(html, pdf_options)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    send_data pdf.to_pdf, :filename => "Meeting_##{@meeting.get_id}.pdf"
  end

end
