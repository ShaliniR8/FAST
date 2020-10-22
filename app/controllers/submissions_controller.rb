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


class SubmissionsController < ApplicationController

  before_filter :set_table_name, :oauth_load # Kaushik Mahorker KM
  before_filter :define_owner
  include Concerns::Mobile # used for [method]_as_json

  def set_table_name
    @table_name = "submissions"
  end


  def define_owner
    @class = Object.const_get('Submission')
    begin
      @owner = Submission.find(params[:id]) if params.key?(:id)
    rescue
      redirect_to eval("#{@class.name.pluralize.underscore}_path"),
      flash: {danger: "Could not find #{@class.name} with ID #{params[:id]}"}
      return false
    end
  end


  def index
    respond_to do |format|
      format.html do
        object_name = controller_name.classify
        @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
        @table = Object.const_get(object_name).preload(@object[:preload]).where("completed is true")
        @default_tab = params[:status]

        records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
        handle_search if params[:advance_search].present?
        records = @records.to_a & records.to_a if @records.present?

        @records_hash = { 'All' => records }
        @records_id   = { 'All' => records.map(&:id) }
      end
      format.json { index_as_json }
    end

    # respond_to do |format|
    #   format.html do
    #     @table = Object.const_get('Submission').preload(CONFIG.hierarchy[session[:mode]][:objects]['Submission'][:preload])
    #     index_meta_field_args, show_meta_field_args = [['index'], ['show']].map do |args|
    #       args << 'admin' if current_user.global_admin? || CONFIG.sr::GENERAL[:show_submitter_name]
    #       args
    #     end
    #     @headers = @table.get_meta_fields(*index_meta_field_args)
    #     @terms = @table.get_meta_fields(*show_meta_field_args).keep_if{
    #       |x|
    #       Rails.logger.info x[:field]
    #       x[:field].present?
    #     }
    #     handle_search

    #     # @categories = Category.all
    #     # @fields = Field.all
    #     # @templates = Template.all

    #     # records = @records
    #     #   .where(:completed => 1)
    #     #   .preload(:template, :created_by)
    #     #   .can_be_accessed(current_user)

    #     # @records = @records.to_a & records.to_a
    #     # records = records.filter_array_by_timerange(@records, params[:start_date], params[:end_date])
    #     # @records = @records.to_a & records.to_a

    #     # if params[:template]
    #     #   records = @records.select{|x| x.template.name == params[:template]}
    #     # end
    #     # @records = @records.to_a & records.to_a

    #     # # handle custom view
    #     # if params[:custom_view].present?
    #     #   selected_attributes = params[:selected_attributes].present? ? params[:selected_attributes] : []
    #     #   @headers = @headers.select{ |header| selected_attributes.include? header[:title] }
    #     #   @headers += format_header(params[:selected_fields]) if params[:selected_fields].present?
    #     # end
    #   end
    #   format.json { index_as_json }
    # end
  end


  def handle_detailed_search
    if params[:detailed_search].present?

      if params[:template_tag].present?
        @records.keep_if {|r| r.template.id.to_s==params[:template_tag]}

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


  def new
    @action = "new"
    @has_template = false
    if !params[:template].blank?
      @template = Template.find(params[:template])
      @has_template = true
      @record = Submission.build(@template)
      @record.submission_fields.build
    else
      @templates = Template.find(:all)
      unless current_user.has_access('submissions', 'admin', admin: true, strict: true)
        @templates.keep_if{|x|
            (current_user.has_template_access(x.name).include? 'full') ||
            (current_user.has_template_access(x.name).include? 'submitter')}
        @templates.sort_by! {|x| x.name }
      end
    end
  end


  def comment
    @owner = Submission.find(params[:id])
    @comment = @owner.comments.new
    render :partial => "notes"
  end


  def search
    @headers = Submission.get_headers
    if params[:base].present?
      result = expand_emit(params[:base])
    end
    if result.blank?
      @records = []
    else
      @records = Submission.find(result)
    end
  end


  def destroy
    @record=Submission.find(params[:id])
    @record.destroy
    redirect_to submissions_path(status: 'All'), flash: {danger: "Submission ##{params[:id]} deleted."}
  end


  def create
    params[:submission][:submission_fields_attributes].each_value do |field|
      if field[:value].is_a?(Array)
        field[:value].delete("")
        field[:value] = field[:value].join(";")
      end
    end

    # edge case for the mobile app
    # if the user submits a new submission in offline mode,
    # and also adds notes in offline mode, treat the commit as a Submit rather than Add Notes
    params[:commit] = 'Submit' if params[:commit] != 'Save for Later'

    params[:submission][:completed] = params[:commit] != 'Save for Later'
    params[:submission][:anonymous] = params[:anonymous] == '1'


    if params[:submission][:attachments_attributes].present?
      params[:submission][:attachments_attributes].each do |key, attachment|
        # File is a base64 string
        if attachment[:name].present? && attachment[:name].is_a?(Hash)
          file_params = attachment[:name]

          temp_file = Tempfile.new('file_upload')
          temp_file.binmode
          temp_file.write(Base64.decode64(file_params[:base64]))
          temp_file.rewind()

          file_name = file_params[:fileName]
          mime_type = Mime::Type.lookup_by_extension(File.extname(file_name)[1..-1]).to_s

          uploaded_file = ActionDispatch::Http::UploadedFile.new(
            :tempfile => temp_file,
            :filename => file_name,
            :type     => mime_type)

          # Replace attachment parameter with the created file
          params[:submission][:attachments_attributes][key][:name] = uploaded_file
        end
      end
    end

    event_date_to_utc

    @record = Submission.new(params[:submission])

    if @record.save
      notify_notifiers(@record, params[:commit])
      if params[:commit] == 'Submit'
        @record.create_transaction(action: 'Create', context: 'User Submitted Report')
        if params[:create_copy] == '1'
          converted = @record.convert
          converted.create_transaction(action: 'Create', context: 'User Submitted Dual Report')
          notify_notifiers(converted, params[:commit])
        end
      end

      respond_to do |format|
        flash = {}
        if params[:commit] == 'Submit'
          flash = { success: 'Submission submitted.' }
          NotifyMailer.send_submitter_confirmation(current_user, @record)
          format.html { redirect_to submission_path(@record), flash: flash }
        else
          flash = { success: 'Submission created in progress.' }
          format.html { redirect_to incomplete_submissions_path, flash: flash }
        end
        format.json { update_as_json(flash) }
      end

    else
      respond_to do |format|
        flash = { danger: @record.errors.full_messages.first }
        format.html { redirect_to new_submission_path(:template => @record.template), flash: flash }
        format.json
      end
    end
  end


  def show
    respond_to do |format|
      format.html do
        @meta_field_args = ['show']
        @meta_field_args << 'admin' if current_user.global_admin?
        @record = Submission.preload(:submission_fields).find(params[:id])
        if !@record.completed
          if @record.user_id == current_user.id
            redirect_to continue_submission_path(@record)
          else
            redirect_to errors_path
          end
        end
        @template = @record.template

        @template_access = @record.user_id == current_user.id ||
          current_user.has_access('submissions', 'admin', admin: true, strict: true) ||
          current_user.has_access(@template.name, 'full', admin: true) ||
          current_user.has_access(@template.name, 'viewer', admin: true)

        redirect_to errors_path unless @template_access

      end
      format.json { show_as_json }
    end
  end


  def incomplete
    @title = "Submissions In Progress"
    @action = "continue"
    @categories = Category.find(:all)
    @headers = Submission.get_headers
    @fields = Field.find(:all)
    @records = Submission.where("user_id=? AND completed is not true ",current_user.id)
  end


  def print
    @deidentified = params[:deidentified]
    @record = Submission.find(params[:id])
    @meta_field_args = ['show']
    @meta_field_args << 'admin' if current_user.global_admin?
    html = render_to_string(:template => "/pdfs/print_submission.html.erb")
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
    filename = "Submission_##{@record.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end


  def update
    alert = ''
    if params[:submission][:submission_fields_attributes].present?
      params[:submission][:submission_fields_attributes].each_value do |field|
        if field[:value].is_a?(Array)
          field[:value].delete("")
          field[:value]=field[:value].join(";")
        end
      end
    end

    if params[:submission][:attachments_attributes].present?
      params[:submission][:attachments_attributes].each do |key, attachment|
        # File is a base64 string
        if attachment[:name].present? && attachment[:name].is_a?(Hash)
          file_params = attachment[:name]
          temp_file = Tempfile.new('file_upload')
          temp_file.binmode
          temp_file.write(Base64.decode64(file_params[:base64]))
          temp_file.rewind()
          file_name = file_params[:fileName]
          mime_type = Mime::Type.lookup_by_extension(File.extname(file_name)[1..-1]).to_s
          uploaded_file = ActionDispatch::Http::UploadedFile.new(
            :tempfile => temp_file,
            :filename => file_name,
            :type     => mime_type)
          params[:submission][:attachments_attributes][key][:name] = uploaded_file
        end
      end
    end

    @record = Submission.find(params[:id])

    # edge case for the mobile app
    # if the user submits an existing in progress submission in offline mode,
    # and also adds notes in offline mode, treat the commit as a Submit rather than Add Notes
    params[:commit] = 'Submit' if !@record.completed? && params[:commit] != 'Save for Later'

    if params[:commit] != 'Add Notes'
      params[:submission][:completed] = params[:commit] != 'Save for Later'
      params[:submission][:anonymous] = params[:anonymous] == '1'
    end

    event_date_to_utc

    if @record.update_attributes(params[:submission])
      notify_notifiers(@record, params[:commit])
      if params[:commit] == "Save for Later"
        respond_to do |format|
          flash = { success: "Submission ##{@record.id} updated." }
          format.html { redirect_to incomplete_submissions_path, flash: flash }
          format.json { update_as_json(flash) }
        end
      else
        if params[:commit] == 'Add Notes'
          @record.create_transaction(action: 'Add Notes', context: 'Additional notes added.')
        else
          @record.create_transaction(action: 'Create', context: 'User Submitted Report')
          NotifyMailer.send_submitter_confirmation(current_user, @record)
        end
        if params[:create_copy] == '1'
          converted = @record.convert
          converted.create_transaction(action: 'Create', context: 'User Submitted Dual Report')
          notify_notifiers(converted, params[:commit])
        end
        respond_to do |format|
          flash = { success: params[:submission][:comments_attributes].present? ? 'Notes added.' : 'Submission submitted.' }
          format.html { redirect_to submission_path(@record), flash: flash }
          format.json { update_as_json(flash) }
        end
      end
    end
  end


  def export
    @submission = Submission.find(params[:id])
    @template = @submission.template
    stream = render_to_string(:template => "submissions/export.xml.erb" )
    send_data(stream, :type=>"text")
  end


  def get_json
    @submission=Submission.find(params[:id])
    @template=@submission.template
    stream = render_to_string(:template=>"submissions/get_json.js.erb" )
    send_data(stream, :type=>"json", :disposition => "inline")
  end


  def advanced_search
    @path = submissions_path
    @search_terms = {
      'Type'              => 'get_template',
      'Submitted By'      => 'submit_name',
      'Last Update'       => 'updated',
      'Submitted At'      => 'submitted_date',
      'Event Date/Time'   => 'get_event_date',
      'Title'             => 'description' }
    render :partial=>"shared/advanced_search"
  end


  def continue
    @action="Continue"
    @record=Submission.find(params[:id])
    @template=@record.template
  end


  def detailed_search
    @categories=Category.find(:all)
    @fields=Field.find(:all)
    @templates=Template.find(:all)
    @templates.sort_by! {|x| x.name }
    render :partial=>"detailed_search"
  end


  def custom_view
    @record_attributes = Submission.get_headers
    @templates=Template.find(:all)
    @templates.sort_by! {|x| x.name }
    @templates.unshift Template.new(id:0, name:'All')
    render :partial=>"shared/custom_view"
  end


  def dynamic_categories
    @categories=Category.where("templates_id=?", params[:temp_id])
    @fields=Field.find(:all, order: :label).uniq_by(&:label).reject{|r| r.label.empty? }
    respond_to do |format|
      format.js { render "shared/dynamic_categories" }
    end
  end


  # Convert the selected fields into Submission.get_headers format
  def format_header(selected_fields)
    selected_fields.map { |field_id|
      {:field=>"get_field", :param=>field_id, :size=>"col-xs-1 col-sm-1 col-md-1 col-lg-1", :title=>Field.find(field_id).label}
    }
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


  private

    def event_date_to_utc
      # Store event_date as UTC
      if CONFIG.sr::GENERAL[:submission_time_zone]
        time_zone = params[:submission]["event_time_zone"]
        date_time = params[:submission]["event_date"]
        utc_time  = convert_to_utc(date_time: date_time, time_zone: time_zone)
        params[:submission]["event_date"] = utc_time
      end
    end

    def notify_notifiers(owner, commit)
      mailer_privileges = AccessControl.where(
        :action => 'notifier',
        :entry => owner.template.name)
        .map{|x| x.privileges.map(&:id)}.flatten
      notifiers = User.preload(:privileges)
        .where("disable is null or disable = 0")
        .keep_if{|x| x.privileges.map(&:id) & mailer_privileges != []}

      case commit
      when "Submit"

        call_rake 'submission_notify',
            owner_type: owner.class.name,
            owner_id: owner.id,
            users: notifiers.map(&:id),
            attach_pdf: CONFIG.sr::GENERAL[:attach_pdf_submission]

      when "Save for Later"
        notify(owner, notice: {
          users_id: owner.created_by.id,
          content: "You have a #{owner.template.name} Submission in progress."},
          mailer: false)
      when "Add Notes"
        notifiers.each do |user|
          notify(owner, notice: {
            users_id: user.id,
            content: "Additional notes have been added to submission ##{owner.id}."},
            mailer: true, subject: 'Additonal Notes Added to Submission')
        end
      else
      end
    end
end
