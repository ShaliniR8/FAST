require 'open-uri'
require 'fileutils'

class Submission < ActiveRecord::Base
  extend AnalyticsFilters
  include Rails.application.routes.url_helpers

#Concerns List
  include Attachmentable
  include Commentable
  include Transactionable

#Association List
  belongs_to :template,   foreign_key: 'templates_id',  class_name: 'Template'
  belongs_to :created_by, foreign_key: 'user_id',       class_name: 'User'
  belongs_to :record,     foreign_key: 'records_id',    class_name: 'Record'

  has_many :submission_fields,    foreign_key: 'submissions_id',  class_name: 'SubmissionField',  dependent: :destroy
  has_many :notices,              foreign_key: 'owner_id',        dependent: :destroy

  accepts_nested_attributes_for :submission_fields

  after_create :make_report
  after_update :make_report

  def create_transaction(action: nil, context: nil)
    Transaction.build_for(
      self,
      action,
      session[:simulated_id] || session[:user_id],
      context,
      nil,
      nil,
      session[:platform]
    )
    handle_anonymous_reports
  end


  # if submission is completed, check whether it's submitted anonymously and update transactions if needed
  def handle_anonymous_reports
    transactions.where(action: ['Add Attachment', 'Create', 'Add Notes']).update_all(users_id: nil) if anonymous
  end


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'admin'] : args)
    submitter_visible = "admin#{CONFIG::SR::GENERAL[:show_submitter_name] ? ',index,show' : ''}"
    [
      {field: 'get_id',             title: 'ID',              num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: 'get_template',       title: 'Submission Type', num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: 'get_submitter_name', title: 'Submitted By',    num_cols: 6,  type: 'text',     visible: submitter_visible, required: false},
      {field: 'event_date',         title: 'Event Date/Time', num_cols: 6,  type: 'datetime', visible: 'index,show',      required: false},
      {field: 'description',        title: 'Event Title',     num_cols: 12, type: 'text',     visible: 'index,show',      required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_user_id
    anonymous ? 'Anonymous' : user_id
  end

  def get_submitter_name
    anonymous ? 'Anonymous' : created_by.full_name
  end


  def getEventId
    if self.record.present? && self.record.report.present?
      self.record.report.id
    end
  end


  def getTimeZone()
    ['Z','NZDT','IDLE','NZST','NZT','AESST','ACSST','CADT','SADT','AEST','CHST','EAST','GST',
     'LIGT','SAST','CAST','AWSST','JST','KST','MHT','WDT','MT','AWST','CCT','WADT','WST',
     'JT','ALMST','WAST','CXT','MMT','ALMT','MAWT','IOT','MVT','TFT','AFT','MUT','RET',
     'SCT','IRT','IT','EAT','BT','EETDST','HMT','BDST','CEST','CETDST','EET','FWT','IST',
     'MEST','METDST','SST','BST','CET','DNT','FST','MET','MEWT','MEZ','NOR','SET','SWT',
     'WETDST','GMT','UT','UTC','ZULU','WET','WAT','FNST','FNT','BRST','NDT','ADT','AWT',
     'BRT','NFT:NST','AST','ACST','EDT','ACT','CDT','EST','CST','MDT','MST','PDT','AKDT',
     'PST','YDT','AKST','HDT','YST','MART','AHST','HST','CAT','NT','IDLW']
  end


  def self.export_all
    submissions = self.where(:completed => true)
    submissions.keep_if{|x| x.template.report_type == 'asap'}
    submissions.each do |s|
      employee_group = s.template.emp_group
      if s.event_date.present?
        event_time = s.event_date
        year = event_time.strftime('%Y')
        month = event_time.strftime('%b').downcase
        dirname = Rails.root.join('mitre', year, month, employee_group)
        temp_file = Rails.root.join('mitre', year, month, employee_group, "#{s.id}.xml")
      else
        dirname = Rails.root.join('mitre', 'no_date', employee_group)
        temp_file = Rails.root.join('mitre', 'no_date', employee_group, "#{s.id}.xml")
      end
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      File.open(temp_file, 'w') do |file|
        file << ApplicationController.new.render_to_string(
          template: 'submissions/export_component.xml.erb',
          locals:   { template: s.template, submission: s})
      end
    end
  end


  def self.get_headers
      [
        {field: 'get_id',            title: 'ID'},
       ({field: 'get_description',   title: 'Title'} if CONFIG::SR::GENERAL[:submission_description]),
        {field: 'get_template',      title: 'Type'},
        {field: 'submit_name',       title: 'Submitted By'},
        {field: 'get_event_date',    title: 'Event Date'},
      ].compact
  end


  def get_id
    custom_id || id
  end


  def get_event_date
    event_date.strftime("%Y-%m-%d %H:%M:%S") rescue ''
  end


  def self.get_terms
    {
      'Type'              => 'get_template',
      'Submitted By'      => 'submit_name',
      'Last Update'       => 'updated',
      'Submitted At'      => 'submitted_date',
      'Event Date/Time'   => 'get_event_date',
      'Title'             => 'description'
    }
  end


  def get_field(id)
    submission_fields.find_by_fields_id(id).present? ? f.value : ''
  end


  def get_field_by_label(label)
    submission_fields.where(fields_id: Field.where(label: label.map(&:id)))
    fields_id = Field.where(label: label).map(&:id)
    submission_fields.where(fields_id: fields_id).present? ? f.first.value : ''
  end


  def submit_name
    return 'Anonymous' if self.anonymous?
    return self.created_by.full_name if self.created_by.present?
    return 'Disabled'
  end


  def get_date
    event_date.strftime("%Y-%m-%d") rescue ''
  end


  def get_time
    event_date.strftime("%H:%M") rescue ''
  end


  def get_description
    return '' if self.description.blank?
    return self.description[0..50] + '...' if self.description.length > 50
    return self.description
  end


  def get_template
    template.name
  end


  def submitted_date
    created_at.strftime("%Y-%m-%d")
  end


  def updated
    updated_at.strftime("%Y-%m-%d")
  end


  def self.build(template)
    self.new(templates_id: template.id)
  end


  def categories
    template.categories
  end


  def time_diff(base)
    ((event_date - base.event_date) / (24 * 60 * 60)).abs
  end


  def make_report
    if completed && records_id.blank?
      record = Record.create(
        templates_id:       templates_id,
        description:        description,
        event_date:         event_date,
        users_id:           user_id,
        status:             'New',
        anonymous:          anonymous,
        event_time_zone:    event_time_zone,
        attachments:        [].tap{ |att| self.attachments.each{ |x| att.push(x.clone) } },
      )
      self.save
      submission_fields.each do |f|
        rf = RecordField.new(
          records_id: record.id,
          fields_id: f.fields_id,
          value: f.value)
        rf.save
      end
      record.handle_anonymous_reports
    end
  end


  def find_field(field_name)
    possible_fields = template.fields.where('label = ?',field_name)
    if possible_fields.present?
      sub_field = submission_fields
        .where('fields_id = ?', possible_fields.first.id)
      return sub_field.first.value if sub_field.present?
    end
    return ''
  end


  def get_narratives #Was used in older xml file exports for asap reports for mitre before refactoring
    [].tap { |ret|
      submission_fields.where(
        fields_id: template.fields.where("label like '%narrative%'").map(&:id))
      .each do |f|
        ret.push(f.first.value)
      end
    }.join('\n')
  end


  def satisfy(conditions)
    conditions.each do |c|
      # get all candidate fields
      field = submission_fields.where('fields_id = ?', c.field_id).first
      # if submission_field exists
      if field.present?
        case field.field.display_type

        # fields that are checkboxes needs to be dissambled
        when 'checkbox'
          return (c.value - field.value.split(';')).empty?

        # dropdown items needs to match exactly
        when 'dropdown'
          return field.value == c.value

        # fields that are date/datetime needs to be searched based on start/end date
        when %w[date datetime]
          if field.field.data_type == 'date'
            field_val = field.value.present? ? Date.parse(field.value) : nil
          else #datetime
            field_val = field.value.present? ? DateTime.parse(field.value) : nil
          end
          return field_val.present? &&
            c.start_date.present? &&
            c.end_date.present? &&
            field_val.between?(c.start_date, c.end_date)

        # all other display types
        else
          return false if (c.value.present?) && (!field.value.downcase.include? c.value.downcase)
        end
      end
      # otherwise submission_fields does not exist
      return true
    end
  end


  def convert
    if template.map_template.present?
      temp_id = template.map_template_id
      new_temp = Template.find(temp_id)
      converted = self.class.create({
        anonymous:        self.anonymous,
        templates_id:     temp_id,
        description:      self.description + ' -- dual report',
        event_date:       self.event_date,
        user_id:          self.user_id,
        event_time_zone:  self.event_time_zone,
      })

      mapped_fields = self.submission_fields.map{|x| [x.field.map_id, x.value]}.to_h

      columns = [:value, :fields_id, :submissions_id]
      values = []
      new_temp.fields.each do |field|
        values << [mapped_fields[field.id], field.id, converted.id]
      end
      SubmissionField.transaction do
        values.each do |value|
          SubmissionField.create({
            value:          value[0],
            fields_id:      value[1],
            submissions_id: value[2]
          })
        end
      end

      self.attachments.each do |x|
        temp = Attachment.new(
          name:       x.name,
          caption:    x.caption)
        converted.attachments.push(temp)
      end
      converted.completed = self.completed
      converted.save
    end
    converted
  end

end
