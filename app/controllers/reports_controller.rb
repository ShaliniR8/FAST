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


class ReportsController < ApplicationController

  before_filter :login_required
  before_filter :set_table_name
  before_filter :check_group, :only => [:show]




  def check_group
    report = Report.find(params[:id])
    if current_user.global_admin?
      true
    elsif (report.privileges.reject(&:blank?).present? rescue false)
      current_user.privileges.each do |p|
        if report.get_privileges.include? p.id.to_s
          true
        end
      end
      redirect_to errors_path
      false
    else
      true
    end
  end



  def load_options
    @action_headers = CorrectiveAction.get_headers
    @suggestion_headers = RecordSuggestion.get_headers
    @description_headers = RecordDescription.get_headers
    @cause_headers = RecordCause.get_headers
    @detection_headers = RecordDetection.get_headers
    @reaction_headers = RecordReaction.get_headers
    @users = User.find(:all)
    @headers = User.get_headers
    @frequency = (0..4).to_a.reverse
    @like = Record.get_likelihood
    risk_matrix_initializer
  end
  helper_method :load_options




  def set_table_name
    @table_name = "reports"
  end




  def reopen
    @report = Report.find(params[:id])
    new_status = @report.meetings.present? ? "Under Review" : "New"
    @report.reopen(new_status)
    redirect_to report_path(@report), flash: {danger: "Event ##{params[:id]} reopened."}
  end




  def destroy
    @report = Report.find(params[:id])
    @report.records.each do |r|
      r.report = nil
      r.status = "Open"
      r.save
    end
    @report.destroy
    redirect_to reports_path, flash: {danger: "Event ##{params[:id]} deleted."}
  end




  def meeting_ready
    report = Report.find(params[:id])
    unless report.can_meeting_ready?(current_user)
      redirect_to report_path(report), flash: { error: 'Unable to make event meeting ready' }
      return
    end
    report.status = "Meeting Ready"
    Transaction.build_for(
      report,
      'Meeting Ready',
      current_user.id
    )
    if report.save
      redirect_to report_path(report)
    end
  end




  def carryover
    report = Report.find(params[:id])
    meeting = Meeting.find(params[:meeting_id])
    report.agendas.where(owner_id: params[:meeting_id]).map(&:destroy) rescue
      Rails.logger.warning "Report ##{report.id} Carryover failed to delete proper agendas
        from Meeting ##{params[:meeting_id]}"
    connection = Connection.get(meeting, report).update_attributes(archive: true)
    Transaction.build_for(
      meeting,
      'Carry Over Event',
      current_user.id,
      "Event ##{report.get_id} Carried Over"
    )
    Transaction.build_for(
      report,
      'Carried Over',
      current_user.id,
      "Event Carried Over from Meeting ##{meeting.id}"
    )
    report.update_attributes(status: 'Meeting Ready') if report.active_meetings.empty?
    report.save
  end




  def new
    load_options
    @action = "new"
    @privileges = Privilege.find(:all)
    @report = Report.new
    if params[:base_record].present?
      base = Record.find(params[:base_record])
      base.report = @report
      @report.records.push(base)
    end
    @fields = Report.get_meta_fields('form', CONFIG.sr::GENERAL[:event_summary] ? 'event_summary' : '')
    @report_fields = Record.get_meta_fields('index')
    @candidates = Record
      .find(:all)
      .select{|x| x.status == "Open" && x.report.blank?} - @report.records
    @candidates.sort_by!{|x| x.event_date}.reverse!
    load_special_matrix_form('report', 'baseline', @report)
  end




  def create
    @report = Report.new(params[:report])
    @report.status = "New"
    @report.save
    if !params[:records].blank?
      params[:records].each_pair do |index,value|
        record = Record.find(value);
        record.report = @report
        record.status = "Linked"
        Transaction.build_for(
          record,
          'Add to Event',
          current_user.id
        )
        record.save
      end
    end
    content = params[:content].blank? ? "User Created Event" : params[:content]
    Transaction.build_for(
      @report,
      'Create',
      current_user.id,
      content
    )
    redirect_to report_path(@report), flash: {success: "Event created."}
  end




  def edit
    load_options
    @privileges = Privilege
      .find(:all)
      .keep_if{|p| keep_privileges(p, 'reports')}
      .sort_by!{|a| a.name}
    @action = "edit"
    @report = Report.find(params[:id])
    @fields = Report.get_meta_fields('form', CONFIG.sr::GENERAL[:event_summary] ? 'event_summary' : '')
    load_special_matrix_form('report', 'baseline', @report)
    if @report.status == "Closed"
      redirect_to report_path(@report)
    end
    @report_fields = Record.get_meta_fields('index')
    @candidates = Record.where(:status => 'Open') - @report.records
  end

  def override_status
    @owner = Report.find(params[:id]).becomes(Report)
    render :partial => '/forms/workflow_forms/override_status'
  end


  def update
    transaction = true
    @owner = Report.find(params[:id])

    if !params[:privileges].present?
      @owner.privileges = nil
    end

    if params[:dettach].present?
      params[:dettach].each_pair do |index, value|
        record = Record.find(value)
        record.report = nil
        record.status = "Open"
        record.save
      end
    end
    if params[:records].present?
      params[:records].each_pair do |index, value|
        record = Record.find(value);
        record.report = @owner
        record.status = "Linked"
        record.save
      end
    end

    case params[:commit]
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:report][:status]}"
      params[:report][:close_date] = params[:report][:status] == 'Closed' ? Time.now : nil
    when 'Add Meeting Minutes'
      redirect_path = meeting_path(params[:meeting_id])
      Transaction.build_for(
        @owner.meetings.first,
        params[:commit],
        current_user.id,
        "Event ##{@owner.get_id}"
      )
    when 'Close Event'
      unless @owner.can_close?(current_user)
        redirect_to redirect_path || report_path(@owner), flash: { error: 'Unable to close event' }
        return
      end
      close_records(@owner)
      @owner.close_date = Time.now
      @owner.child_connections.where(owner_type: 'Meeting').update_all(complete: true)
      redirect_path = params[:redirect_path]
    when 'Add Attachment'
      transaction = false
    end

    @owner.update_attributes(params[:report])
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.save
    redirect_to redirect_path || report_path(@owner)
  end




  def show
    load_options
    @i18nbase = 'sr.event'
    @report = Report.find(params[:id])
    @records = @report.records
    @action = "show"
    @headers = Record.get_headers
    @agenda_headers = AsapAgenda.get_headers
    @title = "Included Reports"
    @table_name = "reports"
    @action_headers = CorrectiveAction.get_meta_fields('index')
    @corrective_actions = @report.corrective_actions
    load_special_matrix(@report)
    @fields = Report.get_meta_fields('show', CONFIG::GENERAL[:event_summary] ? 'event_summary' : '')
  end


  def close
    @fields = Report.get_meta_fields('close')
    @owner = Report.find(params[:id])
    if @owner.has_open_asap
      render :partial => 'reports/close'
    else
      params[:commit] = "close_event"
      render :partial => '/forms/workflow_forms/process', locals: {status: 'Closed', field: "notes"}
    end
  end


  def comment
    @owner = Report.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end


  def print
    @deidentified = params[:deidentified]
    @report = Report.find(params[:id])
    html = render_to_string(:template => "/reports/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Event_##{@report.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end




  def index
    @table = Object.const_get("Report").preload(:records => [:created_by])
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    @title = "Events"
    handle_search
  end


  def summary
    @table = Object.const_get("Report")
    @title = "Events Reporting Summary"
    @action = "report"
    @adv_only = true

    @headers = Report.get_summary_headers
    @records = Report.within_timerange(params[:start_date], params[:end_date])

    Rails.logger.debug "records=#{@records.length}"
    if params[:status].present?
      if params[:status]=="Overdue"
        @records=@records.select{|x| x.overdue}
      else
        @records=@records.select{|x| x.status==params[:status]}
      end
      @title+=" : #{params[:status]}"
    end
    handle_search
    #@records.keep_if{|r|(current_user.has_template_access(r.template.name).include? "full")|| ((current_user.has_template_access(r.template.name).include? "viewer")&&r.viewer_access)}
    Rails.logger.debug "records=#{@records.length}"
    Rails.logger.debug "records=#{@records.length}"
    @records.keep_if{|r| display_in_table(r)}
  end

  def tabulation
    @title="Events Tabulation"
    @action="report"
    @types=Report.get_label_options
    @fiscal_years=Report.all.map(&:get_fiscal_year).uniq.sort
  end



  def add
    @headers = Report.get_headers
    @records = Report.where(:status => 'New')
  end




  def bind
    @record = Record.find(params[:record])
    @report = Report.find(params[:report])
    @record.report = @report
    @record.status = "Linked"
    @record.save
    redirect_to report_path(@report)
  end




  def add_meeting
    @report_headers = Report.get_meta_fields('index', 'meeting')
    @meeting = Meeting.find(params[:meeting])
    @report = Report.find(params[:id])
    Connection.create(owner: @meeting, child: @report)
    @report.status = "Under Review"
    Transaction.build_for(
      @report,
      'Under Review',
      current_user.id,
      "Add to Meeting ##{@meeting.id}"
    )
    Transaction.build_for(
      @meeting,
      'Added Event',
      current_user.id,
      "Event ##{@report.get_id}"
    )
    if @report.save
      render :partial=> "report"
    end
  end




  def get_agenda
    @report = Report.find(params[:id])
    @meeting = Meeting.find(params[:meeting])
    @headers = AsapAgenda.get_headers
    @status = AsapAgenda.get_status
    @tof = {"Yes" => true,"No" => false}
    @accept_deline = {"Accepted" => true, "Declined" => false}
    render :partial => "agenda"
  end

  def new_attachment
    @owner = Report.find(params[:id])
    @attachment = Attachment.new
    render :partial => "shared/attachment_modal"
  end


  def change_privilege
    @privileges = Privileges.find(:all)
    @target = Report.find(params[:id])
    render :partial => "shared/privilege"
  end


  def mitigate
    @owner=Report.find(params[:id])
    load_options
    load_special_matrix_form('report', 'mitigate', @owner)
    if CONFIG::GENERAL[:base_risk_matrix]
        render :partial=>"shared/mitigate"
      else
        render :partial=>"shared/#{AIRLINE_CODE}/mitigate"
      end
  end


  def baseline
    @owner=Report.find(params[:id])
    load_options
    load_special_matrix_form('report', 'baseline', @owner)
    if CONFIG::GENERAL[:base_risk_matrix]
      render :partial=>"shared/baseline"
    else
      render :partial=>"shared/#{AIRLINE_CODE}/baseline"
    end
  end


  def new_minutes
    @owner = Report.find(params[:id])
    @meeting = Meeting.find(params[:meeting])
    render :partial => "shared/add_minutes"
  end


  def show_narrative
    @owner = Report.find(params[:id])
    @meeting = Meeting.find(params[:meeting])
    render :partial => "show_narrative"
  end


  def airport_data
    icao = "%"+params[:icao]+"%"
    iata = "%"+params[:iata]+"%"
    arpt_name = "%"+params[:arpt_name]+"%"
    @records = Airport.where("icao LIKE ? AND faa_host_id LIKE ? AND name LIKE ?", icao, iata, arpt_name)
    @headers = Airport.get_header
    render :partial => "airports"
    #render :partial => "records/record_table"
  end


  private

  def close_records(owner)
    owner.records.each do |record|
      if record.status != 'Closed'
        record.close_date = Time.now
        record.update_attributes(params[:report]) if record.is_asap
        record.status = 'Closed'
        record.save
        submission = record.submission
        if submission.present?
          notify(record.submission, notice: {
            users_id: record.created_by.id,
            content: "Your submission ##{record.submission.id} has been closed by analyst."},
            mailer: true, subject: "Submission ##{record.submission.id} Closed by Analyst")
          Transaction.build_for(
            submission,
            'Close',
            current_user.id,
            'Report has been closed.'
          )
        end
        Transaction.build_for(
          record,
          'Close',
          current_user.id,
          'Report has been closed.'
        )
      end
    end
  end


end
