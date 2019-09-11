class Record < ActiveRecord::Base
  extend AnalyticsFilters
  include RiskHandling

#Concerns List
include Attachmentable
include Commentable
include Investigationable
include Sraable
include Transactionable
include Messageable

#Associations List
  has_one     :submission,          :foreign_key => "records_id",       :class_name => "Submission"
  has_one     :investigation,       as: :owner

  belongs_to  :template,            :foreign_key => "templates_id",     :class_name => "Template"
  belongs_to  :created_by,          :foreign_key => "users_id",         :class_name => "User"
  belongs_to  :report,              :foreign_key => "reports_id",       :class_name => "Report"

  has_many    :record_fields,       :foreign_key => "records_id",       :class_name => "RecordField",           :dependent => :destroy
  has_many    :suggestions,         :foreign_key => "owner_id",         :class_name => "RecordSuggestion",      :dependent => :destroy
  has_many    :descriptions,        :foreign_key => "owner_id",         :class_name => "RecordDescription",     :dependent => :destroy
  has_many    :causes,              :foreign_key => "owner_id",         :class_name => "RecordCause",           :dependent => :destroy
  has_many    :detections,          :foreign_key => "owner_id",         :class_name => "RecordDetection",       :dependent => :destroy
  has_many    :reactions,           :foreign_key => "owner_id",         :class_name => "RecordReaction",        :dependent => :destroy
  has_many    :corrective_actions,  :foreign_key => "records_id",       :class_name => "CorrectiveAction",      :dependent => :destroy

  accepts_nested_attributes_for :suggestions
  accepts_nested_attributes_for :descriptions
  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :detections
  accepts_nested_attributes_for :suggestions
  accepts_nested_attributes_for :record_fields
  accepts_nested_attributes_for :descriptions

  after_create -> { create_transaction(context: 'Generated Report From User Submission.') if !self.description.include?('-- copy')}


  def handle_anonymous_reports
    if anonymous
      transactions.update_all(users_id: nil)
    end
  end


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    submitter_visible = "admin#{CONFIG::SR::GENERAL[:show_submitter_name] ? ',index,show' : ''}"
    [
      {field: 'get_id',                title: 'ID',                   num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: 'status',                title: 'Status',               num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: 'get_template',          title: 'Type',                 num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: 'get_submitter_name',    title: 'Submitted By',         num_cols: 6,  type: 'text',     visible: submitter_visible, required: false},
      {field: 'viewer_access',         title: 'Viewer Access',        num_cols: 6,  type: 'boolean',  visible: 'index,show',      required: false},
      {field: 'event_date',            title: 'Event Date/Time',      num_cols: 6,  type: 'datetime', visible: 'form,index,show', required: false},
      {field: 'description',           title: 'Event Title',          num_cols: 12, type: 'text',     visible: 'form,index,show', required: false},
      {field: 'final_comment',         title: 'Final Comment',        num_cols: 12, type: 'text',     visible: 'show',            required: false},

      {field: 'likelihood',           title: 'Baseline Likelihood',   num_cols: 12, type: 'text',     visible: 'adv',             required: false},
      {field: 'severity',             title: 'Baseline Severity',     num_cols: 12, type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor',          title: 'Baseline Risk',         num_cols: 12, type: 'text',     visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',     title: 'Mitigated Likelihood',  num_cols: 12, type: 'text',     visible: 'adv',             required: false},
      {field: 'severity_after',       title: 'Mitigated Severity',    num_cols: 12, type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor_after',    title: 'Mitigated Risk',        num_cols: 12, type: 'text',     visible: 'index',           required: false,  html_class: 'get_after_risk_color'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_submitter_name
    anonymous ? 'Anonymous' : created_by.full_name
  end


  def self.progress
    {
      "New"       => { :score => 25,  :color => "default"},
      "Open"      => { :score => 50,  :color => "warning"},
      "Linked"    => { :score => 75,  :color => "warning"},
      "Closed"    => { :score => 100, :color => "success"},
    }
  end


  def get_user_id
    anonymous ? 'Anonymous' : users_id
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


  def set_extra
    if self.severity_extra.blank?
      self.severity_extra = []
    end
    if self.severity_extra.blank?
      self.probability_extra = []
    end
    if self.mitigated_severity.blank?
      self.mitigated_severity = []
    end
    if self.mitigated_probability.blank?
      self.mitigated_probability = []
    end
  end


  def self.get_headers
    if CONFIG::SR::GENERAL[:submission_description]
      [
        {:field => :get_id,                     :title => "ID"                                                                      },
        {:field => :get_description,            :title => "Event Title"                                                                   },
        {:field => :get_template,               :title => "Type"                                                                    },
        {:field => :submit_name,                :title => "Submitted By"                                                            },
        {:field => :get_event_date,             :title => "Event Date"                                                              },
        {:field => :status,                     :title => "Status"                                                                  },
        {:field => :get_viewer_access,          :title => "Viewer Access"                                                           },
        # {:field => :display_before_risk_factor, :title => "Baseline Risk",  :html_class => :get_before_risk_color },
        # {:field => :display_after_risk_factor,  :title => "Mitigated Risk", :html_class => :get_after_risk_color  },
      ]
    else
      [
        {:field => :get_id,                     :title => "ID"                                                                      },
        {:field => :get_template,               :title => "Type"                                                                    },
        {:field => :submit_name,                :title => "Submitted By"                                                            },
        {:field => :get_event_date,             :title => "Event Date"                                                              },
        {:field => :status,                     :title => "Status"                                                                  },
        {:field => :get_viewer_access,          :title => "Viewer Access"                                                           },
        # {:field => :display_before_risk_factor, :title => "Baseline Risk",  :html_class => :get_before_risk_color },
        # {:field => :display_after_risk_factor,  :title => "Mitigated Risk", :html_class => :get_after_risk_color  },
      ]
    end
  end


  def get_viewer_access
    if self.viewer_access
      "Yes"
    else
      "No"
    end
  end


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def get_event_date
    self.event_date.strftime("%Y-%m-%d %H:%M:%S")
  end


  def self.get_terms
    {
      "Type"                      =>  "get_template",
      "Status"                    =>  "status",
      "Submitted By"              =>  "submit_name",
      "Last Update"               =>  "updated_date",
      "Submitted At"              =>  "submitted_date",
      "Event Date/Time"           =>  "get_event_date",
      "Title"                     =>  "description",
      "Likelihood"                =>  "likelihood",
      "Severity"                  =>  "severity",
      "Likelihood (Mitigated)"    =>  "likelihood_after",
      "Severity (Mitigated)"      =>  "severity_after",
      "Risk Factor (Mitigated)"   =>  "risk_factor_after"
    }
  end


  def get_field(id)
    f = self.record_fields.find_by_fields_id(id)
    f.present? ? f.value : ""
  end


  def get_field_by_label(label)
    fields = Field.where(:label => label)
    fields_id = fields.collect{|x| x.id}
    f = self.record_fields.where(:fields_id => fields_id)
    f.present? ? f.first.value : ""
  end


  def submit_name
    if self.anonymous?
      'Anonymous'
    else
      self.created_by.full_name
    end
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
    self.created_at.strftime("%Y-%m-%d") rescue ''
  end


  def updated_date
    self.updated_at.strftime("%Y-%m-%d") rescue ''
  end


  def self.getStatus
    ["New", "In Progress", "Closed"]
  end


  def self.build(template)
    record = self.new()
    record.templates_id = template.id
    record
  end


  def categories
    self.template.categories
  end


  def all_causes
    self.suggestions + self.descriptions + self.causes + self.detections + self.reactions
  end


  def time_diff(base)
    if self.event_date.blank?
      100000.0
    else
      diff = ((self.event_date - base.event_date) / (24*60*60)).abs
    end
  end


  def get_date
    self.event_date.strftime("%Y-%m-%d") rescue ''
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


  def self.get_avg_complete(current_user)
    candidates = self.where("status = ? and close_date is not ?", "Closed", nil)
    candidates.keep_if{|r| current_user.has_access(r.template.name, "full" ) }
    if candidates.present?
      sum = 0
      candidates.map{|x| sum += (x.close_date.to_date - x.created_at.to_date).to_i}
      result = (sum.to_f / candidates.length.to_f).round(1)
      result
    else
      "N/A"
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


end
