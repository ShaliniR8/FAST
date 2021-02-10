class Record < Sr::SafetyReportingBase
  extend AnalyticsFilters
  include RiskHandling
  include ModelHelpers

#Concerns List
  include Attachmentable
  include Commentable
  include Investigationable
  include Messageable
  include RootCausable
  include Sraable
  include Transactionable
  include Childable
  include Parentable

#Associations List
  has_one     :submission,          foreign_key: 'records_id',   class_name: 'Submission'
  has_one     :investigation,       as: :owner

  belongs_to  :template,            foreign_key: 'templates_id', class_name: 'Template'
  belongs_to  :created_by,          foreign_key: 'users_id',     class_name: 'User'
  belongs_to  :report,              foreign_key: 'reports_id',   class_name: 'Report'

  has_many    :record_fields,       foreign_key: 'records_id',   class_name: 'RecordField',        dependent: :destroy
  has_many    :suggestions,         foreign_key: 'owner_id',     class_name: 'RecordSuggestion',   dependent: :destroy
  has_many    :descriptions,        foreign_key: 'owner_id',     class_name: 'RecordDescription',  dependent: :destroy
  has_many    :causes,              foreign_key: 'owner_id',     class_name: 'RecordCause',        dependent: :destroy
  has_many    :detections,          foreign_key: 'owner_id',     class_name: 'RecordDetection',    dependent: :destroy
  has_many    :reactions,           foreign_key: 'owner_id',     class_name: 'RecordReaction',     dependent: :destroy
  has_many    :corrective_actions,  foreign_key: 'records_id',   class_name: 'CorrectiveAction',   dependent: :destroy

  accepts_nested_attributes_for :suggestions
  accepts_nested_attributes_for :descriptions
  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :detections
  accepts_nested_attributes_for :suggestions
  accepts_nested_attributes_for :record_fields
  accepts_nested_attributes_for :descriptions

  after_create -> { create_transaction(context: 'Generated Report From User Submission.') if self.description.present? && !self.description.include?('-- copy')}


  def handle_anonymous_reports
    transactions.update_all(users_id: nil) if anonymous
  end


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    CONFIG.object['Record'][:fields].values.select{ |f| (f[:visible].split(',') & visible_fields).any? }
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Record'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                           .map { |key, _| key.to_s }

    keys[keys.index('submitter')] = 'users.full_name' if keys.include? 'submitter'
    keys[keys.index('template')] = 'templates.name' if keys.include? 'template'
    keys[keys.index('occurrences')] = 'occurrences.value' if keys.include? 'occurrences'

    keys
  end


  def self.progress
    {
      "New"       => { :score => 25,  :color => "default"},
      "Open"      => { :score => 50,  :color => "warning"},
      "Linked"    => { :score => 75,  :color => "warning"},
      "Closed"    => { :score => 100, :color => "success"},
    }
  end


  def is_asap
    self.template.report_type == 'asap'
  end


  def reopen(new_status)
    self.status = new_status
    self.close_date = nil
    Transaction.build_for(
      self,
      'Reopen',
      (session[:simulated_id] || session[:user_id])
    )
    self.save
  end


  # whether the current user can access this record
  def to_show
    current_user = User.find(session[:user_id])
    if current_user == created_by
      true
    else
      accesses = current_user.has_template_access(template.name).split(";")
      if accesses.include?("full") || accesses.include?("viewer")
        true
      end
    end
    false
  end


  def self.get_headers
    [
      {field: :get_id,              title: 'ID'              },
     ({field: :get_description,     title: 'Event Title'     } if CONFIG.sr::GENERAL[:submission_description]),
      {field: :get_template,        title: 'Type'            },
      {field: :submit_name,         title: 'Submitted By'    },
      {field: :get_event_date,      title: 'Event Date'      },
      {field: :status,              title: 'Status'          },
      {field: :get_viewer_access,   title: 'Viewer Access'   },
    ]
  end


  def get_viewer_access
    self.viewer_access ? 'Yes' : 'No'
  end


  def self.get_terms
    {
      'Type'                      =>  'get_template',
      'Status'                    =>  'status',
      'Submitted By'              =>  'submit_name',
      'Last Update'               =>  'updated_date',
      'Submitted At'              =>  'submitted_date',
      'Event Date/Time'           =>  'get_event_date',
      'Title'                     =>  'description',
      'Likelihood'                =>  'likelihood',
      'Severity'                  =>  'severity',
      'Likelihood (Mitigated)'    =>  'likelihood_after',
      'Severity (Mitigated)'      =>  'severity_after',
      'Risk Factor (Mitigated)'   =>  'risk_factor_after'
    }
  end


  def get_field(id)
    self.record_fields.find_by_fields_id(id).present? ? f.value : ''
  end


  def get_field_by_label(label)
    fields = Field.where(:label => label)
    fields_id = fields.collect{|x| x.id}
    f = self.record_fields.where(:fields_id => fields_id)
    f.present? ? f.first.value : ''
  end


  def updated_date
    self.updated_at.strftime("%Y-%m-%d") rescue ''
  end


  def self.getStatus
    ["New", "In Progress", "Closed"]
  end

  def get_cisp_timezone
    timezone = {"UTC" => "UTC"}
    # if record has old time zone
    if CONFIG::CISP_TIMEZONES.keys.include? self.event_time_zone
      timezone = {self.event_time_zone => CONFIG::CISP_TIMEZONES[self.event_time_zone]}
    elsif CONFIG::CISP_TIMEZONES.values.include? self.event_time_zone
      timezone = {CONFIG::CISP_TIMEZONES.key(self.event_time_zone) => self.event_time_zone}
    end
    timezone
  end

  def title
    description
  end


  def self.build(template)
    record = self.new()
    record.templates_id = template.id
    record
  end


  def all_causes
    self.suggestions + self.descriptions + self.causes + self.detections + self.reactions
  end


  def convert(copy=true)
    if copy
      if self.template.map_template.present?
        temp_id = self.template.map_template_id
        new_temp = Template.find(temp_id)
        converted = self.class.create({
          :status => self.status,
          :templates_id => temp_id,
          :description => self.description + " -- copy report of ##{self.id}",
          :users_id => self.users_id,
          :event_date => self.event_date,
          :severity => self.severity,
          :likelihood => self.likelihood,
          :risk_factor => self.risk_factor,
          :statement => (self.statement.present? ? self.statement : ""),
          :likelihood_after => self.likelihood_after,
          :severity_after => self.severity_after,
          :risk_factor_after => self.risk_factor_after,
          :anonymous => self.submission.present? ? self.submission.anonymous : self.anonymous
        })
        self.record_fields.each do |f|
          if f.map_field.present?
            RecordField.create({
              :value => f.value,
              :records_id => converted.id,
              :fields_id => f.field.map_id})
          end
        end
        self.all_causes.each do |f|
          f.class.create(
            :category => f.category,
            :value => f.value,
            :owner_id => converted.id,
            :attr => f[:attr])
        end
        new_temp.categories.each do |cat|
          cat.fields.each do |f|
            if converted.record_fields.where('fields_id = ?', f.id).blank?
              RecordField.create({
                :value => "",
                :records_id => converted.id,
                :fields_id => f.id})
            end
          end
        end
        Transaction.build_for(
          converted,
          "Copy",
          session[:user_id],
          "Copied Report From ##{self.id}")
      end
    else
      if self.template.map_template.present?
        temp_id = self.template.map_template_id
        new_temp = Template.find(temp_id)
        self.update_attributes({:templates_id => temp_id, :description => (self.description + " -- converted from #{self.template.name}")})
        self.record_fields.each do |f|
          if f.map_field.present?
            f.update_attributes({:fields_id => f.field.map_id})
          else
            f.destroy
          end
        end
        new_temp.categories.each do |cat|
          cat.fields.each do |f|
            if self.record_fields.where('fields_id = ?', f.id).blank?
              RecordField.create({
                :value => "",
                :records_id => self.id,
                :fields_id => f.id})
            end
          end
        end
        Transaction.build_for(
          self,
          "Convert",
          session[:user_id],
          "Report Converted From #{self.template.name}")
      end
    end
  end

  def satisfy(conditions)

    conditions.each do |c|
      fields = self.record_fields.where('fields_id = ?', c.field_id)
      if fields.present?
        field = fields.first
        if field.field.display_type == "checkbox"
          condition_values = c.value.present? ? c.value.split(";") : []
          flag = false
          condition_values.each do |c_value|
            if field.value.include?(c_value.strip)
              flag = true
            end
          end
          return flag

        elsif field.field.display_type == "dropdown"
          condition_values = c.value.present? ? c.value.split(";") : []
          flag = false
          condition_values.each do |c_value|
            if field.value.include?(c_value.strip)
              flag = true
            end
          end
          return flag

        # fields that are date/datetime needs to be searched based on start/end date
        elsif field.field.data_type == "date" || field.field.data_type == "datetime"
          if field.field.data_type == "date"
            field_val = field.value.present? ? Date.parse(field.value) : nil
          elsif field.field.data_type == "datetime"
            field_val = field.value.present? ? DateTime.parse(field.value) : nil
          end

          if field_val.present? &&
            c.start_date.present? &&
            c.end_date.present? &&
            field_val.between?(c.start_date, c.end_date)
          else
            return false
          end

        else
          condition_values = c.value.present? ? c.value.split(";") : []
          flag = false
          condition_values.each do |c_value|
            if field.value.include?(c_value.strip)
              flag = true
            end
          end
          return flag
        end

      else
        return true
      end
    end
    return true
  end


  def has_emp
    self.corrective_actions.each do |c|
      if c.employee
        return true
      end
    end
    if self.report.present?
      self.report.corrective_actions.each do |x|
        if x.employee
          return true
        end
      end
    end
    false
  end


  def has_com
    self.corrective_actions.each do |c|
      if c.company && c.recommendation
        return true
      end
    end
    if self.report.present?
      self.report.corrective_actions.each do |x|
        if x.company && x.recommendation
          return true
        end
      end
    end
    false
  end


  def get_instructions
    case status
    when 'New'
      "
        Click on <b>Open Report</b> to start processing the Report.</br>
        Submitter will be notified when Report is being opened.
      "
    when 'Open'
      "
        <li><b>Create Event</b> - Create a new Event and include the Report in the Event.</li>
        <li><b>Add to Event</b> - Add Report to an existing Event.</li>
        <li><b>Close Report</b> - Close the Report. Once Report is closed, no changes can be made to it.</li>
      "
    else

    end
  end

  def getEventId
    self.report.id rescue nil
  end

  def self.export_all
    date_from = (Time.now - 1.month).at_beginning_of_month
    date_to = (Time.now - 1.month).end_of_month

    all_records = Record.includes(template: { categories: :fields }).where(templates:{report_type: 'asap'}).where([
"event_date >= ? and event_date <= ?", date_from, date_to])

    all_record_fields = []
    all_records.each { |record| all_record_fields << record.record_fields.map{|sf| [sf.fields_id, sf]} }
    all_record_fields = all_record_fields.flatten(1).to_h

    all_records.each do |s|

      path = ['mitre'] + (s.event_date.strftime('%Y:%b').split(':') rescue ['no_date']) + [s.template.emp_group]
      dirname = File.join([Rails.root] + path)
      temp_file = File.join([Rails.root] + path + ["#{s.id}.xml"])
      unless File.directory?(dirname)
        FileUtils.mkdir_p(dirname)
      end
      File.open(temp_file, 'w') do |file|
        file << ApplicationController.new.render_to_string(
          template: 'records/export_component.xml.erb',
          locals:   { template: s.template, record: s, all_record_fields: all_record_fields})
      end
    end
  end


  def get_additional_info
    additional_info = []
    all_record_fields = self.record_fields.map{|sf| [sf.fields_id, sf] }.to_h
    additional_info_fields = self.template.fields.select { |field| field.additional_info && !field.deleted }

    additional_info_fields.each do |field|
      if all_record_fields[field.id].present?
        additional_info << { label: field.label, value: all_record_fields[field.id].value }
      end
    end

    additional_info
  end

end
