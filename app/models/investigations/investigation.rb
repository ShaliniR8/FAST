class Investigation < ActiveRecord::Base
  extend AnalyticsFilters
  include StandardWorkflow
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Contactable
  include Costable
  include Findingable
  include Noticeable
  include Recommendationable
  include Signatureable
  include SmsActionable
  include SmsTaskable
  include Transactionable

#Associations List
  belongs_to :responsible_user,         :foreign_key => "responsible_user_id",  :class_name => "User"
  belongs_to :approver,                 :foreign_key => "approver_id",          :class_name => "User"
  belongs_to :record,                   :foreign_key => "record_id",            :class_name => "Record"
  belongs_to :created_by,               foreign_key: 'created_by_id',           class_name: 'User'
  has_many :causes,                     :foreign_key => "owner_id",             :class_name => "InvestigationCause",            :dependent => :destroy
  has_many :descriptions,               :foreign_key => "owner_id",             :class_name => "InvestigationDescription",      :dependent => :destroy

  has_many    :checklists, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :descriptions

  serialize :privileges

  before_create :set_priveleges
  after_create :create_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                         title: 'ID',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                      title: 'Title',                         num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {field: 'get_source',                 title: 'Source of Input',               num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'status',                     title: 'Status',                        num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',              title: 'Created By',                    num_cols: 6,  type: 'user',         visible: 'show',            required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'viewer_access',              title: 'Viewer Access',                 num_cols: 6,  type: 'boolean_box',  visible: 'show',            required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'completion',                 title: 'Scheduled Completion Date',     num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'responsible_user_id',        title: 'Investigator',                  num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',                title: 'Final Approver',                num_cols: 6,  type: 'user',         visible: 'form,show',       required: false},
      {field: 'event_occured',              title: 'Date/Time When Event Occurred', num_cols: 6,  type: 'datetime',     visible: 'form,show',       required: false},
      {field: 'local_event_occured',        title: 'Local Time When Event Occurred',num_cols: 6,  type: 'datetime',     visible: 'form,show',       required: false},
      {field: 'inv_type',                   title: 'Investigation Type',            num_cols: 6,  type: 'datalist',     visible: 'index,form,show', required: false,    options: get_custom_options('Investigation Types')},
      {field: 'source',                     title: 'Source',                        num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,    options: get_custom_options('Sources')},
      {field: 'ntsb',                       title: 'NTSB Reportable',               num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'safety_hazard',              title: 'Safety Hazard',                 num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'containment',                title: 'Containment',                   num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'notes',                      title: 'Notes',                         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'description',                title: 'Description of Event',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'investigator_comment',       title: 'Investigator Comment',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',              title: 'Final Comment',                 num_cols: 12, type: 'text',         visible: 'show',            required: false},

      {field: 'likelihood',           title: 'Baseline Likelihood',       num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity',             title: 'Baseline Severity',         num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor',          title: 'Baseline Risk',             num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',     title: 'Mitigated Likelihood',      num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity_after',       title: 'Mitigated Severity',        num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor_after',    title: 'Mitigated Risk',            num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_after_risk_color'},

    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Investigator',
      30 => 'Admin',
    }
  end


  def self.progress
    {
      "New"               => { :score => 25,  :color => "default"},
      "Assigned"          => { :score => 50,  :color => "warning"},
      "Pending Approval"  => { :score => 75,  :color => "warning"},
      "Completed"         => { :score => 100, :color => "success"},
    }
  end


  def get_source
    if self.record.present?
      "<a style='font-weight:bold' href='/records/#{self.record.id}'>
        Report ##{self.record.id}
      </a>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end
  end


  def get_privileges
    self.privileges.present? ?  self.privileges : []
  end


  def set_priveleges
    if self.privileges.blank?
      self.privileges=[]
    end
  end


  def investigation_type
    self.inv_type
  end


  def get_investigator_name
    self.responsible_user.present? ? self.responsible_user.full_name : ""
  end


  def get_approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def get_scheduled_date
    self.completion.present? ?  (self.completion.strftime("%Y-%m-%d")) : ""
  end


  def overdue
    self.completion.present? ? self.completion < Time.now.to_date&&self.status!="Completed" : false
  end


  def type
    return "Investigation"
  end


  def get_event_occured_date
    self.event_occured.present? ? (self.event_occured.strftime("%Y-%m-%d %H:%M")) : ""
  end


  def get_local_date
    self.local_event_occured.present? ? (self.local_event_occured.strftime("%Y-%m-%d %H:%M")) : ""
  end


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def get_ntsb
    return ntsb ? "Yes" : "No"
  end


  def get_safety_hazard
    return safety_hazard ? "Yes" : "No"
  end


  def self.get_terms
    {
      "Title"                                         => "title",
      "Status"                                        => "status",
      "Investigator"                                  => "get_investigator_name",
      "Final Approver"                                => "get_approver_name",
      "Scheduled Completion Date"                     => "get_scheduled_date",
      "NTSB Reportable"                               => "get_ntsb",
      "Safety Hazard"                                 => "get_safety_hazard",
      "Date/Time When Event Occurred"                 => "get_event_occured_date",
      "Local Time When Event Occurred"                => "get_local_date",
      "Source"                                        => "source",
      "Type"                                          => "inv_type",
      "Containment"                                   => "containment",
      "Notes"                                         => "notes",
      "Description of Event"                          => "description",
      "Severity"                                      => "severity",
      "Likelihood"                                    => "likelihood",
      "Risk Factor"                                   => "risk_factor",
      "Likelihood (Mitigated)"                        => "likelihood_after",
      "Severity (Mitigated)"                          => "severity_after",
      "Risk Factor (Mitigated)"                       => "risk_factor_after"
    }.sort.to_h
  end


  def self.get_avg_complete
    candidates=self.where("status=? and complete_date is not ?","Completed",nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.complete_date-x.created_at.to_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


end
