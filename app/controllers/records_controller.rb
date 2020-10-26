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


class RecordsController < ApplicationController

  before_filter :set_table_name, :login_required
  before_filter :check_user_privilege, only: [:query_all, :observation_phases_trend]

  def check_user_privilege
    if current_user.has_access('home','query_all', admin: true)
      true
    else
      flash[:no_access] = 'You do not have access to this function.'
      redirect_to( :home_index )
      false
    end
  end



  def set_table_name
    @table_name = "records"
  end



  def load_options
    @action_headers = CorrectiveAction.get_meta_fields('index')
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



  def comment
    @owner = Record.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "forms/viewer_comment"
  end



  def enable
    record = Record.find(params[:id])
    record.viewer_access = !record.viewer_access
    Transaction.build_for(
      record,
      "#{(record.viewer_access ? 'Enable' : 'Disable')} Viewer Access",
      current_user.id)
    record.save
    redirect_to record_path(record)
  end



  def reopen
    record = Record.find(params[:id])
    new_status = record.report.present? ? "Linked" : "Open"
    record.reopen(new_status)
    redirect_to record_path(record), flash: {danger: "Report ##{params[:id]} reopened."}
  end




  def open
    @record = Record.find(params[:id])
    @record.status = 'Open'
    Transaction.build_for(
      @record.submission,
      'Open', current_user.id,
      'Report has been opened.'
    )
    Transaction.build_for(
      @record,
      'Open',
      current_user.id,
      'Report Opened.'
    )
    begin #TODO - Review case for if submission is deleted then report is opened
      notify(@record.submission, notice: {
        users_id: @record.created_by.id,
        content: "Your submission ##{@record.submission.id} has been opened by analyst."},
        mailer: true, subject: "Submission ##{@record.submission.id} Opened by Analyst")
    rescue
    end
    @record.save
    redirect_to @record, flash: {success: "Report Opened."}
  end



  def index
    object_name = controller_name.classify
    @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
    @table = Object.const_get(object_name).preload(@object[:preload])
    @default_tab = params[:status]

    records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
    handle_search if params[:advance_search].present?
    records = @records.to_a & records.to_a if @records.present?

    @records_hash = records.group_by(&:status)
    @records_hash['All'] = records
    @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  end


  # def index_old
  #   @table = Object.const_get("Record").preload(CONFIG.hierarchy[session[:mode]][:objects]['Record'][:preload])
  #   index_meta_field_args, show_meta_field_args = [['index'], ['show']].map do |args|
  #     args << 'admin' if (current_user.global_admin? || CONFIG.sr::GENERAL[:show_submitter_name])
  #     args
  #   end
  #   @headers = @table.get_meta_fields(*index_meta_field_args)
  #   @terms = @table.get_meta_fields(*show_meta_field_args).keep_if{|x| x[:field].present?}
  #   @title = 'Reports'
  #   handle_search

  #   @fields = Field.find(:all)
  #   @categories = Category.find(:all)
  #   @templates = Template.find(:all)

  #   records = Record.preload(:created_by, :template).can_be_accessed(current_user)
  #   records = Record.filter_array_by_emp_groups(records, params[:emp_groups])

  #   @records = @records.to_a & records.to_a

  #   # handle custom view
  #   if params[:custom_view].present?
  #     selected_attributes = params[:selected_attributes].present? ? params[:selected_attributes] : []
  #     @headers = @headers.select{ |header| selected_attributes.include? header[:title] }
  #     @headers += format_header(params[:selected_fields]) if params[:selected_fields].present?
  #   end
  # end



  def handle_detailed_search
    if params[:detailed_search].present?
      if params[:template_tag].present?
        @records.keep_if {|r| r.template.id.to_s == params[:template_tag]}
        if params[:field_1].present?
          field_id = params[:field_1].split("-")[1]
          if params[:value_1].present?
            @records.keep_if{|r| r.get_field(field_id).downcase.include? params[:value_1].downcase}
          elsif params[:start_date_1].present? && params[:end_date_1].present?
            start_date_1 = params[:start_date_1]
            end_date_1 = params[:end_date_1]
            @records.keep_if{|r| r.get_field(field_id).between?(start_date_1, end_date_1)}
          end
        end
        if params[:field_2].present?
          field_id = params[:field_2].split("-")[1]
          if params[:value_2].present?
            @records.keep_if{|r| r.get_field(field_id).downcase.include? params[:value_2].downcase}
          elsif params[:start_date_2].present? && params[:end_date_2].present?
            start_date_2 = params[:start_date_2]
            end_date_2 = params[:end_date_2]
            @records.keep_if{|r| r.get_field(field_id).between?(start_date_2, end_date_2)}
          end
        end
        if params[:field_3].present?
          field_id = params[:field_3].split("-")[1]
          if params[:value_3].present?
            @records.keep_if{|r| r.get_field(field_id).downcase.include? params[:value_3].downcase}
          elsif params[:start_date_3].present? && params[:end_date_3].present?
            start_date_3 = params[:start_date_3]
            end_date_3 = params[:end_date_3]
            @records.keep_if{|r| r.get_field(field_id).between?(start_date_3, end_date_3)}
          end
        end
      end
    end
  end



  def edit
    start_time = Time.now
    load_options
    @action = "edit"
    @record = Record.find(params[:id])
    load_special_matrix_form("record", "baseline", @record)
    @template = @record.template
    access_level = current_user.has_template_access(@template.name)
    if !(access_level.include? "full")
      redirect_to root_url
      return
    end
    if @record.status == "New"
      @record.status = "Open"
      Transaction.build_for(
        @record,
        'Open',
        current_user.id
      )
      if @record.submission.present?
        Transaction.build_for(
          @record.submission,
          'Open',
          current_user.id,
          'Report has been opened.'
        )
        notify(@record.submission, notice: {
          users_id: @record.created_by.id,
          content: "Your submission ##{@record.submission.id} has been opened by analyst."},
          mailer: true, subject: "Submission ##{@record.submission.id} Opened by Analyst")
      end
    end
    @record.save
    end_time = Time.now
  end



  def search
    @title = "Reports"
    @headers = Record.get_headers
    if params[:base].present?
      result = expand_emit(params[:base])
    else
      result = Record.all.map(&:id)
    end
    if result.blank?
      @records = []
    else
      @records = Record.find(result)
    end
    @templates = Template.where(:id => @records.map(&:templates_id).uniq)
    @fields = []
    @templates.each do |template|
      template.categories.each do |category|
        if category.analytic_fields.present?
          @fields.push(category)
        end
      end
    end
  end



  def destroy
    @record = Record.find(params[:id])
    @record.destroy
    redirect_to records_path(status: 'All'), flash: {danger: "Report ##{params[:id]} deleted."}
  end


  def display
    @record = Record.find(params[:record_id])
    render :partial => "reports/record", locals: {record: @record}
  end


  def emit(expr)
    if expr['temp'].blank?#case of nested
      Rails.logger.debug("Find Nested!")
      base = Record.find(:all).map(&:id)
      if expr['logic'] == "Required" || expr['logic'] == "Optional"
        expand_emit(expr)
      elsif expr['logic'] == "Negation"
        base - expand_emit(expr)
      elsif expr['logic'] == "Greater than" || expr['logic'] == "Less than"
        []
      end
    else
      Rails.logger.debug("No Nested")
      template = Template.find(expr['temp'])
      base = template.records
      fieldid = expr['field'].split("-").last.to_i
      if expr['value'].blank?
        return []
      end


      if expr['logic'] == "Required" || expr['logic'] == "Optional"
        base.keep_if{ |x| (x.record_fields.where(:fields_id => fieldid).present?) && (x.record_fields.where(:fields_id => fieldid).first.value.downcase.include? expr['value'].downcase)}


      elsif expr['logic'] == "Negation"
        base.keep_if{|x|

          ((x.record_fields.where(:fields_id => fieldid).present?)) && (!(x.record_fields.where(:fields_id => fieldid).first.value.downcase.include? expr['value'].downcase))}


      elsif expr['logic'] == "Greater than"
        if Field.find(fieldid).data_type == "datetime" || Field.find(fieldid).data_type == "date"
          base.keep_if{ |x|
            x.record_fields
              .where(:fields_id => fieldid)
              .first.value
              .to_time > expr['value'].to_time}
        else
          base.keep_if{ |x|
            x.record_fields
              .where(:fields_id => fieldid)
              .first.value
              .to_f > expr['value'].to_f}
        end


      elsif expr['logic'] == "Less than"
        if Field.find(fieldid).data_type == "datetime" || Field.find(fieldid).data_type == "date"
          base.keep_if{ |x|
            x.record_fields
              .where(:fields_id => fieldid)
              .first.value
              .to_time < expr['value'].to_time}
        else
          base.keep_if{ |x|
            x.record_fields
              .where(:fields_id => fieldid)
              .first.value
              .to_f < expr['value'].to_f}
        end
      end
      base.map(&:id)
    end
  end



  def expand_emit(expr)
    Rails.logger.debug("Emit Nested")
    result = Record.find(:all).map(&:id)
    expr.each_pair do |index, value|
      if index.to_i > 0
        temp_result = emit(value)
        if value['logic'] == "Optional"
          if temp_result.present?
            result = result | temp_result
          end
        else
          if temp_result.present?
            result = result & temp_result
          end
        end
      end
    end
    result
  end



  def create
    params[:record][:record_fields_attributes].each_value do |field|
      if field[:value].is_a?(Array)
        field[:value].delete("")
        field[:value] = field[:value].join(";")
      end
    end
    @record = Record.new(params[:record])
    @record.status = "New"
    if @record.save
      redirect_to record_path(@record)
    end
  end



  def query
    @fields = Field.find(:all)
    @templates = Template.find(:all)
    @categories = Category.find(:all)
    @logical_types = [
      'Required',
      'Optional',
      'Negation',
      'Greater than',
      'Less than'
    ]
  end



  def show
    load_options
    @i18nbase = 'sr.report'
    @record = Record.find(params[:id])
    @corrective_actions = @record.corrective_actions
    if @record.report.present?
      @corrective_actions << @record.report.corrective_actions
    end
    @template = @record.template
    access_level = current_user.has_template_access(@template.name)
    redirect_to errors_path unless current_user.has_access('records', 'admin', admin: true, strict: true) ||
                              access_level.split(';').include?('full') ||
                              (access_level.split(';').include?('viewer') && @record.viewer_access)
    load_special_matrix(@record)
  end



  def print
    @deidentified = params[:deidentified]
    @record = Record.find(params[:id])
    @meta_field_args = ['show']
    @meta_field_args << 'admin' if current_user.global_admin?
    html = render_to_string(:template => "/pdfs/print_record.html.erb")
    pdf_options = {
      header_html:  'app/views/pdfs/print_header.html',
      header_spacing:  2,
      header_right: '[page] of [topage]'
    }
    if CONFIG::GENERAL[:has_pdf_footer]
      pdf_options.merge!({
        footer_html:  "app/views/pdfs/#{AIRLINE_CODE}/print_footer.html",
        footer_spacing:  3,
      })
    end
    pdf = PDFKit.new(html, pdf_options)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Report_##{@record.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end

  def override_status
    @owner = Record.find(params[:id]).becomes(Record)
    render :partial => '/forms/workflow_forms/override_status'
  end



  def update
    convert_from_risk_value_to_risk_index

    transaction = true
    @owner = Record.find(params[:id])

    if params[:record][:record_fields_attributes].present?
      params[:record][:record_fields_attributes].each_value do |field|
        if field[:value].is_a?(Array)
          field[:value].delete("")
          field[:value] = field[:value].join(";")
        end
      end
    end

    case params[:commit]
    when 'Close'
      if @owner.submission.present?
        notify(@owner.submission, notice: {
          users_id: @owner.created_by.id,
          content: "Your submission ##{@owner.submission.id} has been closed by analyst."},
          mailer: true, subject: "Submission ##{@owner.submission.id} Closed by Analyst")
        Transaction.build_for(
          @owner.submission,
          params[:commit],
          current_user.id,
          'Report has been closed.'
        )
      end
      @owner.close_date = Time.now
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:record][:status]}"
      params[:record][:close_date] = params[:record][:status] == 'Closed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end

    @owner.update_attributes(params[:record])


    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end

    event_date = params[:record][:event_date]

    if CONFIG.sr::GENERAL[:submission_time_zone] && event_date.present?
      @owner.event_date = convert_to_utc(date_time: event_date, time_zone: @owner.event_time_zone)
    end

    @owner.save
    redirect_to record_path(@owner)
  end




  def detailed_search
    @categories = Category.find(:all)
    @fields = Field.find(:all)
    @templates = Template.find(:all)
    @templates.sort_by! {|x| x.name }
    render :partial => "detailed_search"
  end



  def custom_view
    @record_attributes = Record.get_headers
    @templates=Template.find(:all)
    @templates.sort_by! {|x| x.name }
    @templates.unshift Template.new(id:0, name:'All')
    render :partial=>"shared/custom_view"
  end



  def dynamic_categories
    @categories = Category.where("templates_id = ?", params[:temp_id])
    @fields = Field.find(:all, order: :label).uniq_by(&:label).reject{|r| r.label.empty? }
    respond_to do |format|
      format.js { render "shared/dynamic_categories" }
    end
  end



  # Convert the selected fields into Record.get_headers format
  def format_header(selected_fields)
    selected_fields.map { |field_id|
      {:field=>"get_field", :param=>field_id, :size=>"col-xs-1", :title=>Field.find(field_id).label}
    }
  end




  def new_attachment
    @owner = Record.find(params[:id])
    @attachment = Attachment.new
    render :partial => "shared/attachment_modal"
  end



  def convert
    record = Record.find(params[:id])
    record.convert(params[:copy])
    action = params[:copy] ? "Copied" : "Converted"
    redirect_to record_path(record), flash: {success: "Report ##{record.id} #{action}."}
  end



  def mitigate
    @owner = Record.find(params[:id])
    load_special_matrix_form('record', 'mitigate', @owner)
    load_options

    @risk_type = 'Mitigate'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end


  def baseline
    @owner = Record.find(params[:id])
    load_options
    load_special_matrix_form('record', 'baseline', @owner)

    @risk_type = 'Baseline'
    render :partial => 'risk_matrices/panel_matrix/form_matrix/risk_modal'
  end



  def close
    @fields = Record.get_meta_fields('close')
    @owner = Record.find(params[:id])
    if @owner.is_asap
      render partial: 'records/close'
    else
      render partial: '/forms/workflow_forms/process', locals: {status: 'Closed'}
    end
  end



  def observation_phases_trend
    @records = Record.where(id: params[:records].split(","), :templates_id => 25)
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    @table = Object.const_get("Record")
    @headers = @table.get_headers

    @masters = Field.where(:element_class => "master")
    @observation_phases = RecordField
      .where(:fields_id => @masters.map(&:id), :value => "Unsatisfactory", :records_id => @records.map(&:id))
      .group_by(&:fields_id)
      .map{|x, xs| [Field.find(x), xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!

    @following_threats = Field.where(:element_class => "follow threat")
    @threats = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_threats.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!

    @following_subthreats = Field.where(:element_class => "follow subthreat")
    @subthreats = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_subthreats.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!

    @following_err = Field.where(:element_class => "follow err")
    @errs = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_err.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!

    @following_suberr = Field.where(:element_class => "follow suberr")
    @suberrs = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_suberr.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!

    @following_hfactors = Field.where(:element_class => "follow", :display_type => "dropdown")
    @hfactors = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_hfactors.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!
  end



  def filter
    redirect_to observation_phases_trend_records_path(
      :start_date => params[:start_date],
      :end_date => params[:end_date],
      :category_id => params[:category_id],
      :all_categories => params[:all_categories])
  end



  def update_listing_table
    set_table_name
    @table = Object.const_get("Record")
    @headers = @table.get_headers
    @field_id = params[:field_id]
    @records = RecordField.where(
      :fields_id => @field_id,
      :value => "Unsatisfactory").map{|x| x.record}
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    render :partial => "record_listing"
  end



  def update_threat
    @records = Record.where(:templates_id => 25)
    @field_id = params[:field_id]
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    @table = Object.const_get("Record")
    @headers = @table.get_headers
    @type = Field.find(@field_id).element_id
    @following_threats = Field.where(:element_class => "follow threat", :element_id => @type)
    @threats = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_threats.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!
    render :partial => "trend_in_histogram_threat"
  end



  def update_subthreat
    @records = Record.where(:templates_id => 25)
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    @table = Object.const_get("Record")
    @headers = @table.get_headers
    @field_id = params[:field_id]
    @type = nil
    if @field_id.present?
      @type = Field.find(params[:field_id]).element_id
    end
    if params[:threat].present?
      all_following_threats = Field.where(:element_class => "follow threat")
      if @type.present?
        all_following_threats = all_following_threats.where(:element_id => @type)
      end
      records = RecordField.where(
        :fields_id => all_following_threats,
        :value => params[:threat])
        .map{|x| [x.record.id, x.field.element_id]}
      @subthreats = []
      records.each do |x|
        record = x[0]
        element_name = x[1]
        field = Field.where(:element_id => element_name, :element_class => "follow subthreat").first
        @subthreats << RecordField.where(:fields_id => field.id, :records_id => record)
      end
      @subthreats = @subthreats.flatten.group_by(&:value).map{|x, xs| [x, xs.length]}.to_h.sort_by{|k, v| v}.reverse!
    else
      @following_subthreats = Field.where(:element_class => "follow subthreat", :element_id => @type)
      @subthreats = RecordField.where("value is not null and value <> '' ")
            .where(:fields_id => @following_subthreats.map(&:id), :records_id => @records.map(&:id))
            .group_by(&:value)
            .map{|x, xs| [x, xs.length]}
            .to_h.sort_by{|k, v| v}.reverse!    end
    render :partial => "trend_in_histogram_subthreat"
  end



  def update_err
    @records = Record.where(:templates_id => 25)
    @field_id = params[:field_id]
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    @table = Object.const_get("Record")
    @headers = @table.get_headers
    @type = Field.find(@field_id).element_id
    @following_errs = Field.where(:element_class => "follow err", :element_id => @type)
    @errs = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_errs.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!
    render :partial => "trend_in_histogram_err"
  end



  def update_suberr
    @records = Record.where(:templates_id => 25)
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    @table = Object.const_get("Record")
    @headers = @table.get_headers
    @field_id = params[:field_id]
    @type = nil
    if @field_id.present?
      @type = Field.find(params[:field_id]).element_id
    end
    if params[:err].present?
      all_following_errs = Field.where(:element_class => "follow err")
      if @type.present?
        all_following_errs = all_following_errs.where(:element_id => @type)
      end
      records = RecordField.where(:fields_id => all_following_errs, :value => params[:err]).map{|x| [x.record.id, x.field.element_id]}
      @suberrs = []
      records.each do |x|
        record = x[0]
        element_name = x[1]
        field = Field.where(:element_id => element_name, :element_class => "follow suberr").first
        @suberrs << RecordField.where(:fields_id => field.id, :records_id => record)
      end
      @suberrs = @suberrs.flatten.group_by(&:value).map{|x, xs| [x, xs.length]}.to_h.sort_by{|k, v| v}.reverse!
    else
      @following_suberrs = Field.where(:element_class => "follow suberr", :element_id => @type)
      @suberrs = RecordField.where("value is not null and value <> '' ")
            .where(:fields_id => @following_suberrs.map(&:id), :records_id => @records.map(&:id))
            .group_by(&:value)
            .map{|x, xs| [x, xs.length]}
            .to_h.sort_by{|k, v| v}.reverse!
    end
    render :partial => "trend_in_histogram_suberr"
  end



  def update_hfactor
    @records = Record.where(:templates_id => 25)
    @field_id = params[:field_id]
    if params[:start_date].present?
      @start_date = Date.parse(params[:start_date])
      @records.keep_if{|x| x.event_date >= @start_date}
    end
    if params[:end_date].present?
      @end_date = Date.parse(params[:end_date])
      @records.keep_if{|x| x.event_date <= @end_date}
    end
    @table = Object.const_get("Record")
    @headers = @table.get_headers
    @type = Field.find(@field_id).element_id
    @following_hfactors = Field.where(:element_class => "follow", :display_type => "dropdown", :element_id => @type)
    @hfactors = RecordField.where("value is not null and value <> ''")
      .where(:fields_id => @following_hfactors.map(&:id), :records_id => @records.map(&:id))
      .group_by(&:value)
      .map{|x, xs| [x, xs.length]}
      .to_h.sort_by{|k, v| v}.reverse!
    render :partial => "trend_in_histogram_human_factors"
  end



  def airport_data
    icao = "%"+params[:icao].upcase+"%"
    iata = "%"+params[:iata].upcase+"%"
    arpt_name = "%"+params[:arpt_name]+"%"
    @field_id = params[:field_id]
    #@records = Airport.where("MATCH (icao) AGAINST (?) AND MATCH (faa_host_id) AGAINST (?) AND MATCH (name) AGAINST (?)", icao, iata, arpt_name)
    @records = Airport.where("icao LIKE ? AND iata LIKE ? AND airport_name LIKE ?", icao, iata, arpt_name)
    @headers = Airport.get_header
    render :partial => "submissions/airports"
  end





  def draw_chart
    @result = Record.where(:id => params[:records_id].split(","))
    @label = params[:field_id]
    @fields = Field.where(:label => @label)
    @field = @fields.first

    result_id = []
    @result.each{ |r| result_id << r.id }

    # Create Hash to store value and occurance
    @data = Hash.new
    @fields_id = @fields.collect{|x| x.id}
    fields = RecordField.where(:fields_id => @fields_id, :records_id => result_id)
    # Create Hash for each checkbox options
    if @field.display_type == "checkbox"
      @fields.each do |f|
        hash = Hash.new
        hash = Hash[f.getOptions.collect { |item| [item, 0] } ]
        @data = @data.merge(hash)
      end
    # Create key value pair for unique values
    else
      @data = Hash[RecordField.where(
        :fields_id => @fields.collect{|x| x.id},
        :records_id => result_id)
      .select(:value)
      .map(&:value)
      .uniq
      .collect{|item| [item, 0]}]
    end

    # Iterate through result to update Hash
    @result.each do |r|
      value = r.get_field_by_label(@label)
      if value.present?
        # Split value if field is checkbox
        if @field.display_type == "checkbox"
          value.split(";").each do |option|
            if @data[option] != nil
              @data[option] += 1
            end
          end
        else
          @data[value] += 1
        end
      end
    end
    @data = @data.sort_by{|k, v| v}
    @data = @data.reject{|k, v| v < 1}
    if @data.present?
      @data.reverse!
    end

    if @field.data_type == "datetime" || @field.data_type == "date"
      @daily_data = Hash.new(0)
      @monthly_data = Hash.new(0)
      @yearly_data = Hash.new(0)
      @data.each do |x|
        daily = Time.zone.parse(x[0]).beginning_of_day
        monthly = Time.zone.parse(x[0]).beginning_of_month
        yearly = Time.zone.parse(x[0]).beginning_of_year
        @daily_data[daily] += x[1]
        @monthly_data[monthly] += x[1]
        @yearly_data[yearly] += x[1]
      end
      @daily_data = @daily_data.sort_by{|k,v| k}
      @monthly_data = @monthly_data.sort_by{|k,v| k}
      @yearly_data = @yearly_data.sort_by{|k,v| k}
      render :partial => "/records/query_result/datetime_chart_view"
    else
      render :partial => "/records/query_result/chart_view"
    end
  end




  def query_all
    @fields = Field.where("deleted = 0").map(&:label).uniq!.sort!
    @templates = Template.where("archive = 0").sort_by{|x| x.name}
    @logical_types = ['Equals To', 'Not equal to', 'Greater than', 'Less than']
    @operators = ["AND", "OR"]
  end



  def search_all
    @title = "Reports"
    @headers = Record.get_headers
    @templates = Template.where(:id => params[:templates_id].split(","))
    @fields = Field.where("deleted = 0").map(&:label).uniq!.sort!
    @additional_field_types = ['Description', 'Cause', 'Detection', 'Reaction', 'Suggestion']
    all_records = Record.where(:templates_id => @templates.map(&:id)).map(&:id)
    results = []
    if params[:base].present?
      results = expand_emit_all(params[:base], results, all_records, 'AND')
    else
      results = all_records
    end
    @records = Record.find(results)
  end




  def expand_emit_all(expr, result, all_records, operator)
    expr.each_pair do |index, value|
      if index.to_i > 0
        if !value['operator'].blank?
          operator = value['operator']
        end
        if operator == 'AND'
          temp_result = emit_all(value, all_records, all_records, operator)
        else
          temp_result = emit_all(value, result, all_records, operator)
        end
        if operator == 'AND'
          if result.length == 0
            result = all_records & temp_result
          else
            result = result & temp_result
          end
        else
          result = result | temp_result
        end
      end
    end
    result
  end



  def emit_all(expr, result, all_records, operator)
    base = Record.where(:id => all_records)

    # Nested conditions
    if !expr['operator'].blank?

      if expr['operator'] == 'AND'
        expand_emit_all(expr, all_records, all_records, expr['operator'])
      else
        expand_emit_all(expr, result, all_records, expr['operator'])
      end

    else
      if operator == 'AND'
        base = Record.where(:id => result)
      elsif operator == 'OR'
        base = Record.where(:id => all_records)
      end

      fields_id = Field.where(:label => expr['field']).map(&:id)
      if expr['value'].blank?
        return []
      end

      if fields_id.length > 0
        #  get result from logic
        if expr['logic'] == "Equals To"
          base.keep_if{|x|
            (x.record_fields.where(:fields_id => fields_id).present?) &&
            (x.record_fields.where(:fields_id => fields_id).first.value.downcase.include? expr['value'].downcase)}

        elsif expr['logic'] == "Not equal to"
          base.keep_if{|x|
            ((x.record_fields.where(:fields_id => fields_id).present?)) &&
            (!(x.record_fields.where(:fields_id => fields_id).first.value.downcase.include? expr['value'].downcase))}

        elsif expr['logic'] == "Greater than"
          @field = Field.where(:id => fields_id).first
          if @field.data_type == "datetime" || @field.data_type == "date"
            base.keep_if{ |x|
              x.record_fields
                .where(:fields_id => fields_id)
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .to_time > expr['value'].to_time}
          else
            base.keep_if{ |x|
              x.record_fields
                .where(:fields_id => fields_id)
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .to_f > expr['value'].to_f}
          end

        elsif expr['logic'] == "Less than"
          @field = Field.where(:id => fields_id).first
          if @field.data_type == "datetime" || @field.data_type == "date"
            base.keep_if{ |x|
              x.record_fields
                .where(:fields_id => fields_id)
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .to_time < expr['value'].to_time}
          else
            base.keep_if{ |x|
              x.record_fields
                .where(:fields_id => fields_id)
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .present? &&
              x.record_fields
                .where(:fields_id => fields_id)
                .first.value
                .to_f < expr['value'].to_f}
          end
        end
      else
        return []
      end

      base.map(&:id)

    end

  end


end
