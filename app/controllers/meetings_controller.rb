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

  def update_invitation
    invitation = Invitation.find(params[:invitation])
    invitation.status = 'Attended'
    if invitation.save
      render json: { message: 'success'}
    else
      render json: { message: 'failed'}
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

    rules = AccessControl.preload(:privileges).where(entry: 'meetings', action: ['show'])
    privileges = rules.map(&:privileges).flatten
    users = privileges.map(&:users).flatten.uniq
    @available_participants = User.preload(:invitations).where(id: users.map(&:id)).active
    @report_headers = Report.get_meta_fields('meeting_form')
    @reports = Report.reports_for_meeting
  end


  def show
    @has_status = true
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

    has_access = current_user.has_access('meetings', 'show', admin: CONFIG::GENERAL[:global_admin_default]) && @meeting.has_user(current_user)
    redirect_to errors_path unless has_access

    @fields = Meeting.get_meta_fields('show')
    @headers = User.invite_headers
    @report_headers = Report.get_meta_fields('index', 'meeting')
    @reports = @meeting.reports.sort_by{|x| x.id}
    @available_participants = @meeting.invitations.map{|x| x.user}
    @current_inv = @meeting.invitations.select{|x| x.user == current_user && x.status == "Pending"}.first
  end


  def index
    @table = Object.const_get("Meeting")
    @headers = Meeting.get_meta_fields('index')
    @action = 'meeting'
    # @records = @table.includes(:invitations, :host).where('meetings.type is null')
    # unless current_user.has_access('meetings', 'admin', admin: CONFIG::GENERAL[:global_admin_default], strict: true )
    #   @records = @records.where('(participations.users_id = ? AND participations.status in (?)) OR hosts_meetings.users_id = ?',
    #     current_user.id, ['Pending', 'Accepted'], current_user.id)
    # end
    # @records.keep_if{|r| display_in_table(r)}
    handle_search
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
    @flash_message = nil
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

    transaction_content = params[:meeting][:final_comment] rescue nil
    if transaction_content.nil?
      if params[:meeting][:comments_attributes].present?
        params[:meeting][:comments_attributes].each do |key, val|
          transaction_content = val[:content] rescue nil
        end
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
    when 'Save Corrective Action'
      transaction_content = "Event ##{params[:event_id]}"
    when 'Send to CISP'
      send_cisp_reports
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
    if params[:meeting].present? && params[:meeting][:agendas_attributes].present?
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

    # update included corrective_actions
    if params[:meeting].present? && params[:meeting][:corrective_actions_attributes].present?
      meetings_corrective_actions = Meeting.find(params[:id]).corrective_actions

      corrective_actions = params[:meeting][:corrective_actions_attributes]
      corrective_actions.each do |corrective_action|
        found = false
        meetings_corrective_actions.each do |meeting_corrective_action|
          found = true if meeting_corrective_action.id == corrective_action[1][:id]
        end

        next if found

        Meeting.find(params[:id]).corrective_actions << CorrectiveAction.find(corrective_action[1][:id]) if corrective_action[1][:id].present?
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

    @owner.set_datetimez if params[:commit] == 'Update'
    @owner.save
    redirect_to meeting_path(@owner), flash: @flash_message
  end


  def save_agenda
    @meeting = Meeting.find(params[:id])
    @report_headers = Report.get_meta_fields('index', 'meeting')
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
              else
                if eval(value)[:value].present? && eval(value)[:value] == 1
                  deleted_agenda_ids << agenda_id
                end
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

    # AsapAgenda.where(id: deleted_agenda_ids).map(&:destroy)
    deleted_agenda_ids.each do |a_id|
      ag = AsapAgenda.find(a_id)
      if ag.present?
        update_hash.delete(a_id)
        ag.destroy
      end
    end

    update_hash.each do |k, v|
      ag = AsapAgenda.find(k) rescue nil
      if ag.nil?
        v[:user_id] = eval(params[:user_id])[:value]
        v[:event_id] = params[:event_id]
        v[:owner_id] = params[:id]
        v[:type] = "AsapAgenda"
        AsapAgenda.create(v)
      else
        ag.update_attributes(v)
      end
    end
    @reports = @meeting.reports.sort_by{|x| x.id}

    Transaction.build_for(
      @meeting,
      "Save Agenda",
      current_user.id,
      "Event ##{params[:event_id]}"
    )

    respond_to do |format|
      format.js
    end
  end

  def save_corrective_action
    @meeting = Meeting.find(params[:id])
    @report_headers = Report.get_meta_fields('index', 'meeting')
    update_hash = Hash.new
    deleted_corrective_action_ids = []

    params.each do |key, value|
      if ["reports_id", "created_by_id"].exclude?(key)
        key_parts = key.split('_')
        if key_parts.length == 2
          corrective_action_id = key_parts[1].to_i rescue 0
          if corrective_action_id > 0
            if !update_hash.key?(corrective_action_id)
              update_hash[corrective_action_id] = Hash.new
            end
            if key_parts[0] == 'destroy'
              if eval(value) == true
                deleted_corrective_action_ids << corrective_action_id
              else
                if eval(value)[:value].present? && eval(value)[:value] == 1
                  deleted_corrective_action_ids << corrective_action_id
                end
              end
            elsif key_parts[0] == 'dueDate'
              update_hash[corrective_action_id]['due_date'] = value
            else
              update_hash[corrective_action_id][key_parts[0].to_sym] = value
            end
          end
        end
      end
    end


    # CorrectiveAction.where(id: deleted_corrective_action_ids).map(&:destroy)
    deleted_corrective_action_ids.each do |ca_id|
      coa = CorrectiveAction.find(ca_id)
      if coa.present?
        update_hash.delete(ca_id)
        coa.destroy
      end
    end


    update_hash.each do |k, v|
      coa = CorrectiveAction.find(k) rescue nil
      if coa.nil?
        v[:created_by_id] = eval(params[:created_by_id])[:value]
        v[:reports_id] = params[:event_id]
        v[:status] = 'New'
        CorrectiveAction.create(v)
      else
        coa.update_attributes(v)
      end
    end
    @reports = @meeting.reports.sort_by{|x| x.id}

    Transaction.build_for(
      @meeting,
      "Save Corrective Action",
      current_user.id,
      "Event ##{params[:event_id]}"
    )

    respond_to do |format|
      format.js
    end
  end


  def edit
    @has_status = true
    @privileges = Privilege.find(:all)
    @meeting = Meeting.find(params[:id])
    @action = 'edit'
    @headers = User.invite_headers
    rules = AccessControl.preload(:privileges).where(entry: 'meetings', action: ['show'])
    privileges = rules.map(&:privileges).flatten
    users = privileges.map(&:users).flatten.uniq
    @available_participants = User.preload(:invitations).where(id: users.map(&:id))
    @timezones = Meeting.get_timezones
    @report_headers = Report.get_headers
    @associated_reports = @meeting.reports.map(&:id)
    @reports = Report.reports_for_meeting
  end


  def get_reports
    @report_headers = Report.get_meta_fields('index')
    @meeting = Meeting.find(params[:id])
    @reports = Report.reports_for_meeting
    @reports = @reports.where('id NOT IN (?)', @meeting.reports.map(&:id)) if @meeting.reports.present?
    render :partial => "reports"
  end

  def get_cisp_reports
    @owner = Meeting.find(params[:id])
    keys = CONFIG::CISP_TITLE_PARSE.keys
    @reports = @owner.reports.includes(:records)
    asap_reports = []
    @reports.each do |rep|
      asap_found = false
      rep.records.each do |rec|
        asap_found = true if CONFIG::CISP_TITLE_PARSE[rec.template.name]
        break if asap_found
      end
      asap_reports << rep if asap_found
    end
    @available_reports = asap_reports.select { |report| not report.cisp_sent }
    @report_headers = Report.get_meta_fields('index')
    render :partial => "cisp_reports"
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
        users_id: user.id,
        content: "You have a new internal message sent from Meeting ##{@meeting.id}."},
        mailer: true, subject: 'New Internal Meeting Message')
    end
    redirect_to meeting_path(@meeting)
  end


  def print
    @meeting = Meeting.find(params[:id])
    html = render_to_string(:template=>"/pdfs/print_meeting.html.erb")
    pdf_options = {
      header_html:  'app/views/pdfs/print_header.html',
      header_spacing:  1,

      header_right: '[page] of [topage]'
    }
    if CONFIG::GENERAL[:has_pdf_header]
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


  private

  def send_cisp_reports
    # ex params: "meeting"=>{"reports_attributes"=>{"11"=>{"cisp_sent"=>"0", "id"=>"670"}
    reports_ids = params[:meeting][:reports_attributes].map { |key, val| val[:id] if val[:cisp_sent] == '1' }.compact rescue nil
    if reports_ids.present?
      test_run = Rails.env.production? ? false : true
      timestamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
      Report.export_all_for_cisp(test_run: test_run, reports_ids: reports_ids, timestamp: timestamp)
      # remove extra line
      path = File.join(Rails.root, "cisp")
      file_name = File.join([Rails.root] + ['cisp'] + ["#{AIRLINE_CODE}_CISP_#{timestamp}.xml"])
      original = File.open(file_name, 'r') { |file| file.readlines }
      blankless = original.reject{ |line| line.match(/^$/) }
      File.open(file_name, 'w') do |file|
        blankless.each { |line| file.puts line }
      end

      begin
        unless test_run
          system ("curl -X PUT --url \"https://www.atsapsafety.org/services/cisp/transfer?user=" + AIRLINE_CODE + "\" -k -d @#{file_name}")
        end

        puts 'SENT events to CISP'
        FileUtils.rm_rf(file_name)
        @flash_message = { success: 'Event(s) Sent To CISP.' }
      rescue
        puts 'FAILED to send events to CISP'
      end
    else
      puts 'NO events sent to CISP'
      @flash_message = { danger:  'No Events Sent To CISP.' }
    end
    # render :partial => "cisp_reports_result"
  end
end
