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

  # before_filter :set_table_name,:login_required
  before_filter :set_table_name, :oauth_load # Kaushik Mahorker KM



  def set_table_name
    @table_name = "submissions"
  end



  def mitre_export_all
  end




  def index
    @table = Object.const_get("Submission")
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    @categories = Category.all
    @fields = Field.all
    @templates = Template.all

    records = @records
      .where(:completed => 1)
      .preload(:template, :created_by)
      .can_be_accessed(current_user)

    puts "-------------- @records: #{@records.length}"
    puts "-------------- records: #{records.length}"
    @records = @records.to_a & records.to_a

    puts "-------------- @records: #{@records.length}"
    puts "-------------- records: #{records.length}"
    records = records.filter_array_by_timerange(@records, params[:start_date], params[:end_date])
    @records = @records.to_a & records.to_a


    puts "-------------- @records: #{@records.length}"
    puts "-------------- records: #{records.length}"
    if params[:template]
      records = @records.select{|x| x.template.name == params[:template]}
    end
    @records = @records.to_a & records.to_a


    puts "-------------- @records: #{@records.length}"
    puts "-------------- records: #{records.length}"

    # handle custom view
    if params[:custom_view].present?
      selected_attributes = params[:selected_attributes].present? ? params[:selected_attributes] : []
      @headers = @headers.select{ |header| selected_attributes.include? header[:title] }
      @headers += format_header(params[:selected_fields]) if params[:selected_fields].present?
    end
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
      @templates
        .keep_if{|x|
          (current_user.has_template_access(x.name).include? "full") ||
          (current_user.has_template_access(x.name).include? "submitter")}
      @templates.sort_by! {|x| x.name }
    end
  end



  def comment
    @owner = Submission.find(params[:id])
    @comment = SubmissionNote.new
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
    redirect_to submissions_path, flash: {danger: "Submission ##{params[:id]} deleted."}
  end



  def create
    params[:submission][:submission_fields_attributes].each_value do |field|
      if field[:value].is_a?(Array)
        field[:value].delete("")
        field[:value] = field[:value].join(";")
      end
    end

    params[:submission][:completed] = params[:commit] == 'Submit' ? true : false
    params[:submission][:anonymous] = params[:anonymous] == '1' ? true : false


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
            :type     => mime_type
          )

          # Replace attachment parameter with the created file
          params[:submission][:attachments_attributes][key][:name] = uploaded_file
        end
      end
    end

    @record = Submission.new(params[:submission])

    mailer_privileges = AccessControl.where(
      :action => 'notifier',
      :entry => @record.template.name)
      .map{|x| x.privileges.map(&:id)}.flatten

    notify_users = User.preload(:privileges)
      .where("disable is null or disable = 0")
      .keep_if{|x| x.privileges.map(&:id) & mailer_privileges != []}

    if @record.save
      if params[:commit] == "Submit"
        notify_users.each do |u|
          notify(u, "A new #{@record.template.name} submission ##{@record.id} is submitted. " + g_link(@record),
            true, "New #{@record.template.name} Submission")
        end
        # if crew wants to submit asap/incident as the same time
        if params[:create_copy] == "1"
          converted = @record.convert
          convert_privileges = AccessControl.where(
            :action => 'notifier',
            :entry => converted.template.name)
            .map{|x| x.privileges.map(&:id)}.flatten
          convert_notify_users = User.preload(:privileges)
            .where("disable is null or disable = 0")
            .keep_if{|x| x.privileges.map(&:id) & convert_privileges != []}
          notify_users.each do |u|
            notify(u, "A new #{converted.template.name} submission ##{converted.id} is submitted. " + g_link(converted),
              true, "New #{converted.template.name} Submission")
          end
        end
        respond_to do |format|
          format.html { redirect_to submission_path(@record), flash: {success: "Submission submitted."} }
          format.json
        end
      else
        notify(
          current_user,
          "You have a #{@record.template.name} Submission in progress." + g_link(@record),
          false,
          "#{@record.template.name} Submission In Progress")
        respond_to do |format|
          format.html { redirect_to incomplete_submissions_path, flash: {success: "Submission created in progress."} }
          format.json
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to new_submission_path(:template => @record.template), flash: {danger: @record.errors.full_messages.first} }
        format.json
      end
    end
  end



  def show
    @record = Submission.preload(:submission_fields).find(params[:id])
    if !@record.completed
      if @record.user_id == current_user.id
        redirect_to continue_submission_path(@record)
      else
        redirect_to root_url
      end
    end
    @template = @record.template
    access_level=current_user.has_template_access(@template.name)
    if access_level == "" && @record.user_id != current_user.id
        redirect_to root_url
    elsif (!access_level.include? "full" ) && @record.created_by != current_user && (!access_level.include? "viewer")
        redirect_to root_url
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
    html = render_to_string(:template => "/submissions/print.html.erb")
    pdf = PDFKit.new(html)
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
            :type     => mime_type
          )

          # Replace attachment parameter with the created file
          params[:submission][:attachments_attributes][key][:name] = uploaded_file
        end
      end
    end


    @record = Submission.find(params[:id])
    if params[:commit] == "Submit"


      mailer_privileges = AccessControl.where(
        :action => 'notifier',
        :entry => @record.template.name)
        .map{|x| x.privileges.map(&:id)}.flatten

      notify_users = User.preload(:privileges)
        .where("disable is null or disable = 0")
        .keep_if{|x|
          x.privileges.map(&:id) & mailer_privileges != []}

      notify_users.each do |u|
        if @record.completed?
          notify( u,
            "A note has been added to submission ##{@record.id}. " + g_link(@record),
            true,
            "New ##{@record.id} Submission Note")
        else
          notify( u,
            "A new #{@record.template.name} submission ##{@record.id} is submitted. " + g_link(@record),
            true,
            "New #{@record.template.name} Submission")
        end
      end
      params[:submission][:completed] = true
    else
      params[:submission][:completed] = false
    end
    if @record.update_attributes(params[:submission])
      if params[:commit] == "Submit"
        # if crew wants to submit asap/incident as the same time
        if params[:create_copy] == '1'
          converted = @record.convert
          convert_privileges = AccessControl.where(
            :action => 'notifier',
            :entry => converted.template.name)
            .map{|x| x.privileges.map(&:id)}.flatten
          convert_notify_users = User.preload(:privileges)
            .where("disable is null or disable = 0")
            .keep_if{|x| x.privileges.map(&:id) & convert_privileges != []}
          notify_users.each do |u|
            notify(u, "A new #{converted.template.name} submission ##{converted.id} is submitted. " + g_link(converted),
              true, "New #{converted.template.name} Submission")
          end
        end
        respond_to do |format|
          format.html {
            redirect_to submission_path(@record),
              flash: {success: params[:submission][:comments_attributes].present? ? "Notes added" : "Submission submitted."}
          }
          format.json
        end
      else
        respond_to do |format|
          format.html {
            redirect_to incomplete_submissions_path,
              flash: {success: "Submission ##{@record.id} updated."}
          }
          format.json
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



  def export_all
    #purify_fields
    submissions = Submission.find(:all)
    submissions.keep_if{|x| x.template.report_type == "asap"}
    submissions.each do |s|
      if s.event_date.present?
        event_time = s.event_date
        year = event_time.strftime("%Y")
        month = event_time.strftime("%b").downcase
        employee_group = s.template.emp_group
        dirname = Rails.root.join("mitre", year, month, employee_group)
        temp_file = Rails.root.join('mitre', year, month, employee_group, "#{s.id}.xml")
      else
        dirname = Rails.root.join("mitre", "no_date", employee_group)
        temp_file = Rails.root.join('mitre', "no_date", employee_group, "#{s.id}.xml")
      end
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      File.open(temp_file, 'w') do |file|
        file << ApplicationController.new.render_to_string(
            :template => "submissions/export_component.xml.erb",
            :locals => { :template => s.template, :submission => s})
      end
    end
    redirect_to root_url
  end



  def get_json
    @submission=Submission.find(params[:id])
    @template=@submission.template
    stream = render_to_string(:template=>"submissions/get_json.js.erb" )
    send_data(stream, :type=>"json", :disposition => "inline")
  end



  def advanced_search
    @path = submissions_path
    @terms = Submission.get_terms
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
    #@templates = Template.where("id = 5 or id = 7 or id = 29 or id = 31 or id = 23 or id = 25 or id = 28 or id = 21 or id = 32 or id = 30 or id = 27")
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



  def fsap_all
    @submissions = Submission.find(:all)
    @submissions.keep_if{|x| x.template.id == 31 || x.template.id == 7 || x.template.id == 5 || x.template.id == 22}
    @submissions.each do |x|
      @submission = x
      file = Rails.root.join('nasa',"#{x.id}.xml")
      file = File.open(file, "w")
      file << render_to_string(:template=>"submissions/fsap.xml.erb" )
    end
    redirect_to submissions_path
  end



  def fsap
    @submission = Submission.find(params[:id])
    @template = @submission.template
    stream = render_to_string(:template => "submissions/fsap.xml.erb" )
    send_data(stream, :filename => "fsap_#{params[:id]}.xml", :type => "xml")
  end



  def msap
    @submission = Submission.find(params[:id])
    @template = @submission.template
    stream = render_to_string(:template => "submissions/msap.xml.erb" )
    send_data(stream, :filename => "msap_#{params[:id]}.xml", :type => "xml")
  end



  def csap
    @submission = Submission.find(params[:id])
    @template = @submission.template
    stream = render_to_string(:template => "submissions/csap.xml.erb" )
    send_data(stream, :filename => "csap_#{params[:id]}.xml",:type => "xml")
  end



  def dsap
    @submission = Submission.find(params[:id])
    @template = @submission.template
    stream = render_to_string(:template => "submissions/dsap.xml.erb" )
    send_data(stream, :filename => "dsap_#{params[:id]}.xml", :type => "xml")
  end



  def purify_fields
    all_fields = Field.find(:all)
    all_fields.each do |x|
      if x.display_type == "checkbox"
        x.submission_fields.each do |f|
          if f.value.present?
           f.value = f.value.split(";").select{|x| x.present?}.join(";")
           f.save
          end
        end
      end
    end
  end



  def airport_data
    icao = "%"+params[:icao]+"%"
    iata = "%"+params[:iata]+"%"
    arpt_name = "%"+params[:arpt_name]+"%"
    @field_id = params[:field_id]
    #@records = Airport.where("MATCH (icao) AGAINST (?) AND MATCH (faa_host_id) AGAINST (?) AND MATCH (name) AGAINST (?)", icao, iata, arpt_name)
    @records = Airport.where("icao LIKE ? AND faa_host_id LIKE ? AND name LIKE ?", icao, iata, arpt_name)
    @headers = Airport.get_header
    render :partial => "submissions/airports"
    #render :partial => "records/record_table"
  end






# ------------- BELOW ARE EVERYTHING ADDED FOR PROSAFET APP
  #Added by BP Aug 8. render json for templates accessible to the current user
  def template_json
    @templates = Template.find(:all)
    @templates.keep_if{|x| (current_user.has_template_access(x.name).include? "full")||(current_user.has_template_access(x.name).include? "submitter")}
    stream = render_to_string(:template=>"submissions/template_json.js.erb" )
    send_data(stream, :type => "json", :disposition => "inline")
  end


  def user_submission_json
    @date = params[:date]
    @submissions = Submission.find(:all, :conditions => [ "created_at > ? and user_id = ?",@date,current_user.id])
    # @templates=Template.find(:all)
    stream = render_to_string(:template => "submissions/user_submission_json.js.erb" )
    response.headers['Content-Length'] = stream.bytesize.to_s
    send_data(stream, :type => "json", :disposition => "inline")
  end







end
