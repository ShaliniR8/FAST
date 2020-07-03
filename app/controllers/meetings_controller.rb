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



class MeetingsController < ApplicationController
  before_filter :set_table_name,:login_required
  before_filter :check_group,:only=>[:show]


  def check_group
    report = Meeting.find(params[:id]).becomes(Meeting)
    if (report.privileges.reject(&:blank?).present? rescue false)
      current_user.privileges.each do |p|
        if report.get_privileges.include? p.id.to_s
          return true
        end
      end
      redirect_to errors_path
      return false
    else
      return true
    end
  end


  def reopen
    @meeting = Meeting.find(params[:id]).becomes(Meeting)
    @meeting.status = "Open"
    @meeting.save
    Transaction.build_for(
      @meeting.id,
      'Reopen',
      current_user.id
    )
    redirect_to meeting_path(@meeting)
  end


  def new_attachment
    @owner = Meeting.find(params[:id]).becomes(Meeting)
    @attachment = Attachment.new
    render :partial => "shared/attachment_modal"
  end


  def destroy
    @meeting = Meeting.find(params[:id])
    if @meeting.review_end.blank? || @meeting.meeting_end.blank?
      end_time = Time.now
    else
      end_time = @meeting.review_end > @meeting.meeting_end ? @meeting.review_end  : @meeting.meeting_end
    end

    @meeting.invitations.each do |inv|
      notify(@meeting, notice: {
        users_id: inv.users_id,
        content: "Meeting ##{@meeting.id} has been canceled."},
        mailer: true, subject: "Meeting Canceled")
    end

    @meeting.reports.each do |x|
      Transaction.build_for(
        x,
        'Meeting Ready',
        current_user.id,
        'Meeting Deleted'
      )
      x.status = "Meeting Ready"
      x.records.each do |y|
        y.status = "Linked"
      end
      x.save
    end
    @meeting.destroy
    redirect_to meetings_path(status: 'All'), flash: {danger: "Meeting ##{params[:id]} deleted."}
  end


  def comment
    @owner = Meeting.find(params[:id]).becomes(Meeting)
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end


  def set_table_name
    #Rails.logger.debug "#{controller_name}  #{action_name} set table!"
    @table_name = "meetings"
  end


  def create
    if params[:type].present?
      @meeting = Object.const_get(params[:type]).new(params[:meeting])
    else
      @meeting = Meeting.new(params[:meeting])
    end
    if !params[:reports].blank?
      @meeting.save
      params[:reports].each_pair do |index, report_id|
        report = Report.find(report_id)
        Connection.create(owner: @meeting, child: report)
        report.status = "Under Review"
        Transaction.build_for(
          report,
          'Under Review',
          current_user.id,
          "Add to Meeting ##{@meeting.id}"
        )
        Transaction.build_for(
          @meeting,
          "Added Event ##{report.get_id}",
          current_user.id,
          "Event ##{report.get_id}"
        )
        report.save
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
      redirect_to meeting_path(@meeting), flash: {success: "Meeting created."}
    else
      redirect_to new_meeting_path
    end
  end


  def new
    @privileges = Privilege.find(:all)
    @meeting = Meeting.new
    @action = "new"
    @timezones = Meeting.get_timezones
    @headers = User.invite_headers
    @users = User.find(:all) - [current_user]
    @users.keep_if{|u| !u.disable && u.has_access('meetings', 'index')}
    @report_headers = Report.get_meta_fields('meeting_form')
    @reports = Report.where(status: ['Meeting Ready', 'Under Review'])
  end


  def show
    @meeting = Meeting.find(params[:id])
    if @meeting.type.present?
      case @meeting.type
      when "SrmMeeting"
        redirect_to srm_meeting_path(@meeting)
        return
      else
        redirect_to sms_meeting_path(@meeting)
        return
      end
    end
    @fields = Meeting.get_meta_fields('show')
    @headers = User.invite_headers
    @report_headers = Report.get_meta_fields('index', 'meeting')
    @reports = @meeting.reports.sort_by{|x| x.id}
    @users = @meeting.invitations.map{|x| x.user}
    @current_inv = @meeting.invitations.select{|x| x.user == current_user && x.status == "Pending"}.first
  end


  def index
    @table = Object.const_get("Meeting")
    @headers = Meeting.get_meta_fields('index')
    @title = 'Meetings'
    @action = 'meeting'
    @records = @table.includes(:invitations, :host).where('meetings.type is null')
    unless current_user.has_access('meetings', 'admin', admin: true, strict: true )
      @records = @records.where('(participations.users_id = ? AND participations.status in (?)) OR hosts_meetings.users_id = ?',
        current_user.id, ['Pending', 'Accepted'], current_user.id)
    end
    @records.keep_if{|r| display_in_table(r)}
  end


  def close
    @owner = Meeting.find(params[:id])
    render :partial => '/forms/workflow_forms/process', locals: {status: 'Closed'}
  end


  def override_status
    @owner = Meeting.find(params[:id]).becomes(Meeting)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def update
    transaction = true
    @owner = Meeting.find(params[:id])

    if params[:reports].present?
      params[:reports].each_pair do |index, report_id|
        report = Report.find(report_id)
        Connection.create(owner: @owner, child: report)
        report.status = "Under Review"
        Transaction.build_for(
          report,
          'Under Review',
          current_user.id,
          "Add to Meeting ##{@owner.id}"
        )
        Transaction.build_for(
          @owner,
          "Added Event ##{report.get_id}",
          current_user.id,
          "Event ##{report.get_id}"
        )
        report.save
      end
    end

    case params[:commit]
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:meeting][:status]}"
    when 'Close'
      @owner.invitations.each do |inv|
        notify(@owner, notice: {
          users_id: inv.users_id,
          content: "Meeting ##{@owner.id} has been closed."},
          mailer: true, subject: "Meeting Closed")
      end
    when 'Add Attachment'
      transaction = false
    when 'Save Agenda'
      transaction_content = "Event ##{params[:event_id]}"
    end

    if params[:invitations].present?
      params[:invitations].each_pair do |index, val|
        inv = @owner.invitations.where("users_id = ?", val)
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
      params[:cancellation].each_pair do |index, val|
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


    # update included agendas
    if params[:meeting][:agendas_attributes].present?
      meetings_agendas = Meeting.find(params[:id]).agendas

      agendas = params[:meeting][:agendas_attributes]
      agendas.each do |agenda|
        found = false
        meetings_agendas.each do |meeting_agenda|
          found = true if meeting_agenda.id == agenda[1][:id]
        end

        next if found

        Meeting.find(params[:id]).agendas << Agenda.find(agenda[1][:id]) if agenda[1][:id].present?
      end
    end

    @owner.update_attributes(params[:meeting])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.set_datetimez
    @owner.save
    redirect_to meeting_path(@owner)
  end


  def edit
    @privileges = Privilege.find(:all)
    @meeting = Meeting.find(params[:id])
    @action = 'edit'
    @headers = User.invite_headers
    @users = User.find(:all) - [@meeting.host.user]
    @users.keep_if{|u| !u.disable && u.has_access('meetings', 'index')}
    @timezones = Meeting.get_timezones
    @report_headers = Report.get_headers
    @associated_reports = @meeting.reports.map(&:id)
    @reports = Report.where(status: ['Meeting Ready', 'Under Review'])
  end


  def get_reports
    @report_headers = Report.get_meta_fields('index')
    @meeting = Meeting.find(params[:id])
    @reports = Report.where(status: ['Meeting Ready', 'Under Review'])
    @reports = @reports.where('id NOT IN (?)', @meeting.reports.map(&:id)) if @meeting.reports.present?
    render :partial => "reports"
  end

  def get_cisp_records
    report_name =  CONFIG::CISP_TITLE_PARSE.keys
    @record_headers = Record.get_meta_fields('index')
    @records = Record.includes(:template).where(cisp_ready: true, cisp_sent: false, templates:{name: report_name})
    render :partial => "cisp_records", locals: {sent: false}
  end

  def send_cisp_records
    report_name =  CONFIG::CISP_TITLE_PARSE.keys
    @record_headers = Record.get_meta_fields('index')
    @records = Record.includes(:template).where(cisp_ready: true, cisp_sent: false, templates:{name: report_name})
    @submission_ids = @records.map(&:submission).map(&:id)

    test_run = true
    Submission.export_all_for_cisp(test_run: test_run, submission_ids: @submission_ids)

    # remove extra line
    path = File.join(Rails.root, "cisp")
    file_name = File.join([Rails.root] + ['cisp'] + ["#{AIRLINE_CODE}_CISP.xml"])
    original = File.open(file_name, 'r') { |file| file.readlines }
    blankless = original.reject{ |line| line.match(/^$/) }
    File.open(file_name, 'w') do |file|
      blankless.each { |line| file.puts line }
    end

    begin
      unless test_run
        system ("curl -X PUT --url \"https://www.atsapsafety.com/services/cisp/transfer?user=" + AIRLINE_CODE + "\" -k -d @#{file_name}")
      end

      @records.each do |record|
        record.update_attributes(cisp_sent: true)
      end

      p 'SENT reports to CISP'
    rescue
      p 'FAILED to send reports to CISP'
    end

    render :partial => "cisp_records", locals: {sent: true}
  end

  def message
    @meeting = Meeting.find(params[:id])
    @users = @meeting.invitations.map{|x| x.user}
    @options = Meeting.getMessageOptions
    @headers = User.invite_headers
    render :partial => "message"
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

    message = @meeting.messages.create({
      subject: params[:subject],
      content: params[:message],
      time: Time.now
    })
    sent_from = SendFrom.create(messages_id: message.id, users_id: current_user.id)

    users.each do |user|
      SendTo.create(messages_id: message.id, users_id: user.id)
      notify(message, notice: {
        users_id: user,
        content: "You have a new internal message sent from Meeting ##{@meeting.id}."},
        mailer: true, subject: 'New Internal Meeting Message')
    end
    redirect_to meeting_path(@meeting)
  end


  def print
    @meeting = Meeting.find(params[:id])
    html = render_to_string(:template=>"/meetings/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    send_data pdf.to_pdf, :filename => "Meeting_##{@meeting.get_id}.pdf"
  end


end
