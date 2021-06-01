require 'open-uri'
require 'fileutils'

class Submission < Sr::SafetyReportingBase
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

  accepts_nested_attributes_for :submission_fields

  # after_create :make_report  # Logic moved to Submissions Controller create & update methods
  # after_update :make_report

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
    CONFIG.object['Submission'][:fields].values.select{ |f| (f[:visible].split(',') & visible_fields).any? }
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Submission'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                               .map { |key, _| key.to_s }

    keys[keys.index('submitter')] = 'users.full_name' if keys.include? 'submitter'
    keys[keys.index('template')] = 'templates.name' if keys.include? 'template'

    keys
  end


  def getEventId
    record.report.id rescue nil
  end


  def get_matching_record_id
    if completed && records_id.present?
      records_id
    else
      id
    end
  end


  def self.get_headers
      [
        {field: 'get_id',            title: 'ID'},
       ({field: 'get_description',   title: 'Title'} if CONFIG.sr::GENERAL[:submission_description]),
        {field: 'get_template',      title: 'Type'},
        {field: 'submit_name',       title: 'Submitted By'},
        {field: 'event_date',        title: 'Event Date/Time', type: 'datetime'},
      ].compact
  end


  def get_id
    if CONFIG.sr::GENERAL[:match_submission_record_id]
      get_matching_record_id
    else
      custom_id || id
    end
  end


  def get_field(id)
    submission_fields.find_by_fields_id(id).present? ? f.value : ''
  end


  def get_field_by_label(label)
    submission_fields.includes(:field).where(fields:{label:label}).first.value rescue ''
  end


  def get_time
    event_date.strftime("%H:%M") rescue ''
  end


  def updated
    updated_at.strftime("%Y-%m-%d")
  end


  def title
    description
  end


  def self.build(template)
    self.new(templates_id: template.id)
  end


  def check_immediate_duplicate
    h = Hash.new

    h[:templates_id] = templates_id
    h[:event_date] = event_date
    h[:user_id] = user_id
    h[:anonymous] = anonymous
    h[:confidential] = confidential
    h[:event_time_zone] = event_time_zone

    arr = Submission.where(h)
    if arr.length > 0
      arr.each do |sub|
        if sub.description.include?('-- dual submission of')
          if description == sub.description.split('-- dual submission of')[0].strip
            return false
          end
        else
          if description == sub.description
            return false
          end
        end
      end
    end
    return true
  end


  def make_report
    if completed && records_id.blank?
      self.record = Record.create(
        templates_id:       templates_id,
        description:        description,
        event_date:         event_date,
        users_id:           user_id,
        status:             (self.template.default_status || 'New'),
        anonymous:          anonymous,
        confidential:       confidential,
        event_time_zone:    event_time_zone,
      )

      self.attachments.each do |x|
        temp = Attachment.new(
          :name => x.name,
          :caption => x.caption)
        self.record.attachments.push(temp)
      end

      self.save
      submission_fields.each do |f|
        points = []; # Needed in order to transfer points from submission to record

        if f.points.present?
          f.points.each do |point|
            pt = point.clone;
            points << pt
          end
        end

        RecordField.create(
          records_id: record.id,
          fields_id: f.fields_id,
          value: f.value,
          points: points)
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


  def satisfy(conditions)
    conditions.each do |c|
      # get all candidate fields
      field = submission_fields.where('fields_id = ?', c.field_id).first
      # if submission_field exists
      if field.present?
        case field.field.display_type
        when 'checkbox'
          # fields that are checkboxes needs to be dissambled
          return (c.value - field.value.split(';')).empty?
        when 'dropdown'
          # dropdown items needs to match exactly
          return field.value == c.value
        when %w[date datetime]
          # fields that are date/datetime needs to be searched based on start/end date
          if field.field.data_type == 'date'
            field_val = field.value.present? ? Date.parse(field.value) : nil
          else #datetime
            field_val = field.value.present? ? DateTime.parse(field.value) : nil
          end
          return field_val.present? &&
            c.start_date.present? &&
            c.end_date.present? &&
            field_val.between?(c.start_date, c.end_date)
        else
          # all other display types
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
        confidential:     self.confidential,
        templates_id:     temp_id,
        description:      self.description + " -- dual submission of ##{self.get_id}",
        event_date:       self.event_date,
        user_id:          self.user_id,
        event_time_zone:  self.event_time_zone,
      })

      self.description = self.description + " -- dual submission of ##{converted.get_id}"
      self.save

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
