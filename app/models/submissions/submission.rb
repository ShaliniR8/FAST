require 'open-uri'
require 'fileutils'

class Submission < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Commentable
  include Transactionable

#Association List
  belongs_to :template,   foreign_key: "templates_id",  class_name: "Template"
  belongs_to :created_by, foreign_key: "user_id",       class_name: "User"
  belongs_to :record,     foreign_key: "records_id",    class_name: "Record"

  has_many :submission_fields,    foreign_key: "submissions_id",  class_name: "SubmissionField",        :dependent => :destroy
  has_many :notices,              foreign_key: "owner_id",        class_name: "SubmissionNotice",       :dependent => :destroy

  accepts_nested_attributes_for :submission_fields

  after_create :make_report
  after_create :create_transaction
  after_update :make_report

  extend AnalyticsFilters
  include Rails.application.routes.url_helpers



  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'get_id',         title: 'Submission ID',   num_cols: 6,  type: 'text', visible: 'index,show', required: false},
      {field: 'get_template',   title: 'Submission Type', num_cols: 6,  type: 'text', visible: 'index,show', required: false},
      {field: 'get_user_id',    title: 'Submitted By',    num_cols: 6,  type: 'user', visible: 'index,show', required: false},
      {field: 'get_event_date', title: 'Event Date/Time', num_cols: 6,  type: 'text', visible: 'index,show', required: false},
      {field: 'description',    title: 'Event Title',     num_cols: 12, type: 'text', visible: 'index,show', required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end




  def get_user_id
    anonymous ? 'Anonymous' : user_id
  end




  def getEventId
    if self.record.present? && self.record.report.present?
      self.record.report.id
    end
  end



  def getTimeZone()
    ["Z","NZDT","IDLE","NZST","NZT","AESST","ACSST","CADT","SADT","AEST","CHST","EAST","GST",
     "LIGT","SAST","CAST","AWSST","JST","KST","MHT","WDT","MT","AWST","CCT","WADT","WST",
     "JT","ALMST","WAST","CXT","MMT","ALMT","MAWT","IOT","MVT","TFT","AFT","MUT","RET",
     "SCT","IRT","IT","EAT","BT","EETDST","HMT","BDST","CEST","CETDST","EET","FWT","IST",
     "MEST","METDST","SST","BST","CET","DNT","FST","MET","MEWT","MEZ","NOR","SET","SWT",
     "WETDST","GMT","UT","UTC","ZULU","WET","WAT","FNST","FNT","BRST","NDT","ADT","AWT",
     "BRT","NFT:NST","AST","ACST","EDT","ACT","CDT","EST","CST","MDT","MST","PDT","AKDT",
     "PST","YDT","AKST","HDT","YST","MART","AHST","HST","CAT","NT","IDLW"]
  end



  def self.export_all
    #purify_fields
    submissions = self.where(:completed => true)
    submissions.keep_if{|x| x.template.report_type == "asap"}
    submissions.each do |s|
      employee_group = s.template.emp_group
      if s.event_date.present?
        event_time = s.event_date
        year = event_time.strftime("%Y")
        month = event_time.strftime("%b").downcase
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
  end



  def self.get_headers
    if BaseConfig.airline[:submission_description]
      [
        {:field => "get_id",            :title => "ID"},
        {:field => "get_description",   :title => "Title"},
        {:field => "get_template",      :title => "Type"},
        {:field => "submit_name",       :title => "Submitted By"},
        {:field => "get_event_date",    :title => "Event Date"},
      ]
    else
      [
        {:field => "get_id",            :title => "ID"},
        {:field => "get_template",      :title => "Type"},
        {:field => "submit_name",       :title => "Submitted By"},
        {:field => "get_event_date",    :title => "Event Date"},
      ]
    end
  end



  def get_id
    custom_id || id
  end



  def get_event_date
    event_date.strftime("%Y-%m-%d %H:%M:%S") rescue ''
  end



  def create_transaction
    Transaction.build_for(
      self,
      'Create',
      self.anonymous? ? '' : (session[:simulated_id] || session[:user_id]),
      'User Submitted Report.'
    )
  end



  def self.get_terms
    {
      "Type"              => "get_template",
      "Submitted By"      => "submit_name",
      "Last Update"       => "updated",
      "Submitted At"      => "submitted_date",
      "Event Date/Time"   => "get_event_date",
      "Title"             => "description"
    }
  end



  def get_field(id)
    f = self.submission_fields.find_by_fields_id(id)
    f.present? ? f.value : ""
  end



  def get_field_by_label(label)
    fields = Field.where(:label => label)
    fields_id = fields.collect{|x| x.id}
    f = self.submission_fields.where(:fields_id => fields_id)
    f.present? ? f.first.value : ""
  end



  def submit_name
    if self.anonymous?
      'Anonymous'
    else
      if self.created_by.present?
        self.created_by.full_name
      else
        'Disabled'
      end
    end
  end



  def get_date
    event_date.strftime("%Y-%m-%d") rescue ''
  end



  def get_time
    event_date.strftime("%H:%M") rescue ''
  end



  def get_description
    if self.description.blank?
      ""
    else
      if self.description.length > 50
        self.description[0..50] + "..."
      else
        self.description
      end
    end
  end



  def get_template
    self.template.name
  end



  def submitted_date
    self.created_at.strftime("%Y-%m-%d")
  end



  def updated
    self.updated_at.strftime("%Y-%m-%d")
  end



  def self.build(template)
    record = self.new()
    record.templates_id = template.id
    record
  end



  def categories
    self.template.categories
  end



  def time_diff(base)
    diff = ((self.event_date - base.event_date) / (24 * 60 * 60)).abs
  end



  # Can we find a better way to mass assign values to it?
  def make_report
    if self.completed && self.records_id.blank?
      record = Record.new(
        :templates_id       => self.templates_id,
        :description        => self.description,
        :event_date         => self.event_date,
        :users_id           => self.user_id,
        :status             => "New",
        :anonymous          => self.anonymous,
        :event_time_zone    => self.event_time_zone
      )
    self.attachments.each do |x|
      temp = Attachment.new(
        :name => x.name,
        :caption => x.caption)
      record.attachments.push(temp)
    end
      record.save
      self.records_id = record.id
      self.save
      self.submission_fields.each do |f|
        rf = RecordField.new(
          :records_id => record.id,
          :fields_id => f.fields_id,
          :value => f.value)
        rf.save
      end
    end
  end



  def to_asap
  end



  def find_field(field_name)
    possible_fields = self.template.fields.where('label = ?',field_name)
    if possible_fields.present?
      sub_field = self.submission_fields
        .where('fields_id = ?', possible_fields.first.id)
      if sub_field.present?
        sub_field.first.value
      else
        ''
      end
    else
      ""
    end
  end



  def get_narratives
    result = []
    possible_fields = self.template.fields.where("label like '%narrative%'")
    possible_fields.each do |f|
      sub_field = self.submission_fields.where('fields_id = ?',f.id)
      if sub_field.present?
        result.push(sub_field.first.value)
      else
        ''
      end
    end
    if result.present?
      result.join("\n")
    else
      ''
    end
  end



  def satisfy(conditions)
    conditions.each do |c|
      # get all candidate fields
      fields = self.submission_fields.where('fields_id = ?', c.field_id)

      # if submission_fields exists
      if fields.present?
        field = fields.first

        # fields that are checkboxes needs to be dissambled
        if field.field.display_type == "checkbox"
          if !(c.value - field.value.split(";")).empty?
            return false
          end

        # dropdown items needs to match exactly
        elsif field.field.display_type == "dropdown"
          if field.value == c.value
            return true
          else
            return false
          end

        # fields that are date/datetime needs to be searched based on start/end date
        elsif field.field.data_type == "date" || field.field.data_type == "datetime"
          if field.field.data_type == "date"
            field_val = field.value.present? ? Date.parse(field.value) : nil
          elsif field.field.data_type == "datetime"
            field_val = field.value.present? ? DateTime.parse(field.value) : nil
          end

          if field_val.present? && c.start_date.present? && c.end_date.present? && field_val.between?(c.start_date, c.end_date)
            return true
          else
            return false
          end


        # all other display types
        else
          if (c.value.present?) && (!field.value.downcase.include? c.value.downcase)
            return false
          end
        end

      # if submission_fields does not exist
      else
        return true
      end
    end
  end



  def convert
    if self.template.map_template.present?
      temp_id = self.template.map_template_id
      new_temp = Template.find(temp_id)
      converted = self.class.create({
        :anonymous        => self.anonymous,
        :templates_id     => temp_id,
        :description      => self.description,
        :event_date       => self.event_date,
        :user_id          => self.user_id,
        :event_time_zone  => self.event_time_zone,
      })
      self.submission_fields.each do |f|
        if f.map_field.present?
          SubmissionField.create({
            :value => f.value,
            :submissions_id => converted.id,
            :fields_id => f.field.map_id})
        end
      end
      new_temp.categories.each do |cat|
        cat.fields.each do |f|
          if converted.submission_fields.where('fields_id = ?', f.id).blank?
            SubmissionField.create({
              :value => "",
              :submissions_id => converted.id,
              :fields_id => f.id})
          end
        end
      end
      self.attachments.each do |x|
        temp = Attachment.new(
          :name => x.name,
          :caption => x.caption)
        converted.attachments.push(temp)
      end
      converted.completed = self.completed
      converted.save
    end
    converted
  end





end
