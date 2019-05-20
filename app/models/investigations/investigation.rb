class Investigation < ActiveRecord::Base

  belongs_to :responsible_user,         :foreign_key => "responsible_user_id",  :class_name => "User"
  belongs_to :approver,                 :foreign_key => "approver_id",          :class_name => "User"
  belongs_to :record,                   :foreign_key => "record_id",            :class_name => "Record"
  belongs_to :created_by,              foreign_key: 'created_by_id',           class_name: 'User'
  has_many :attachments,                :foreign_key => 'owner_id',             :class_name => "InvestigationAttachment",       :dependent => :destroy
  has_many :causes,                     :foreign_key => "owner_id",             :class_name => "InvestigationCause",            :dependent => :destroy
  has_many :descriptions,               :foreign_key => "owner_id",             :class_name => "InvestigationDescription",      :dependent => :destroy
  has_many :corrective_actions,         :foreign_key => "owner_id",             :class_name => "InvestigationAction",           :dependent => :destroy
  has_many :comments,                   :foreign_key => "owner_id",             :class_name => "InvestigationComment",          :dependent => :destroy
  has_many :recommendations,            :foreign_key => "owner_id",             :class_name => "InvestigationRecommendation",   :dependent => :destroy
  has_many :contacts,                   :foreign_key => "owner_id",             :class_name => "InvestigationContact",          :dependent => :destroy
  has_many :findings,                   :foreign_key => "audit_id",             :class_name => "InvestigationFinding",          :dependent => :destroy
  has_many :tasks,                      :foreign_key => "owner_id",             :class_name => "InvestigationTask",             :dependent => :destroy
  has_many :costs,                      :foreign_key => "owner_id",             :class_name => "InvestigationCost",             :dependent => :destroy
  has_many :notices,                    :foreign_key => "owner_id",             :class_name => "InvestigationNotice",           :dependent => :destroy
  has_many :transactions,               :foreign_key => "owner_id",             :class_name => "InvestigationTransaction",      :dependent => :destroy

  accepts_nested_attributes_for :corrective_actions
  accepts_nested_attributes_for :contacts
  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :descriptions
  accepts_nested_attributes_for :tasks
  accepts_nested_attributes_for :costs
  accepts_nested_attributes_for :recommendations
  accepts_nested_attributes_for :findings
  accepts_nested_attributes_for :comments
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank?&&attachment[:_destroy].blank?)}

  after_create -> { create_transaction('Create') }
  before_create :set_priveleges

  serialize :privileges
  serialize :severity_extra
  serialize :probability_extra
  serialize :mitigated_severity
  serialize :mitigated_probability
  before_create :set_extra

  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                         title: 'ID',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                      title: 'Title',                         num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'status',                     title: 'Status',                        num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'viewer_access',              title: 'Viewer Access',                 num_cols: 6,  type: 'boolean_box',  visible: 'show',            required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'completion', title: 'Scheduled Completion Date',     num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
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


  def get_privileges
    self.privileges.present? ?  self.privileges : []
  end

  def set_priveleges
    if self.privileges.blank?
      self.privileges=[]
    end
  end

  def set_extra
    if self.severity_extra.blank?
      self.severity_extra=[]
    end
    if self.severity_extra.blank?
      self.probability_extra=[]
    end
    if self.mitigated_severity.blank?
      self.mitigated_severity=[]
    end
    if self.mitigated_probability.blank?
      self.mitigated_probability=[]
    end
  end

  def get_extra_severity
    self.severity_extra.present? ?  self.severity_extra : []
  end
  def get_extra_probability
    self.probability_extra.present? ?  self.probability_extra : []
  end
  def get_mitigated_probability
    self.mitigated_probability.present? ?  self.mitigated_probability : []
  end
  def get_mitigated_severity
    self.mitigated_severity.present? ?  self.mitigated_severity : []
  end

  def create_transaction(action)
    if !self.changes()['viewer_access'].present?
      InvestigationTransaction.create(users_id: (session[:user_id] rescue nil),
          action: action,
          owner_id: self.id,
          content: defined?(session) ? '' : 'Recurring Investigation',
          stamp: Time.now)
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

  def get_before_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_before_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index].index(display_before_risk_factor)
    end
  end

  def get_after_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_after_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index].index(display_after_risk_factor)
    end
  end

  def display_before_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity
    else
      get_risk_values[:severity_1].present? ? get_risk_values[:severity_1] : "N/A"
    end
  end

  def display_before_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood
    else
      get_risk_values[:probability_1].present? ? get_risk_values[:probability_1] : "N/A"
    end
  end

  def display_before_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor.present? ? risk_factor : "N/A"
    else
      get_risk_values[:risk_1].present? ? get_risk_values[:risk_1] : "N/A"
    end
  end

  def display_after_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity_after
    else
      get_risk_values[:severity_2].present? ? get_risk_values[:severity_2] : "N/A"
    end
  end

  def display_after_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood_after
    else
      get_risk_values[:probability_2].present? ? get_risk_values[:probability_2] : "N/A"
    end
  end

  def display_after_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor_after.present? ? risk_factor_after : "N/A"
    else
      get_risk_values[:risk_2].present? ? get_risk_values[:risk_2] : "N/A"
    end
  end

  def get_risk_values
    airport_config = Object.const_get("#{BaseConfig.airline[:code]}_Config")
    matrix_config = airport_config::MATRIX_INFO
    @severity_table = matrix_config[:severity_table]
    @probability_table = matrix_config[:probability_table]
    @risk_table = matrix_config[:risk_table]

    @severity_score = airport_config.calculate_severity(severity_extra)
    @sub_severity_score = airport_config.calculate_severity(mitigated_severity)
    @probability_score = airport_config.calculate_severity(probability_extra)
    @sub_probability_score = airport_config.calculate_severity(mitigated_probability)

    @print_severity = airport_config.print_severity(self, @severity_score)
    @print_probability = airport_config.print_probability(self, @probability_score)
    @print_risk = airport_config.print_risk(@probability_score, @severity_score)

    @print_sub_severity = airport_config.print_severity(self, @sub_severity_score)
    @print_sub_probability = airport_config.print_probability(self, @sub_probability_score)
    @print_sub_risk = airport_config.print_risk(@sub_probability_score, @sub_severity_score)

    {
      :severity_1       => @print_severity,
      :severity_2       => @print_sub_severity,
      :probability_1    => @print_probability,
      :probability_2    => @print_sub_probability,
      :risk_1           => @print_risk,
      :risk_2           => @print_sub_risk,
    }
  end
  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def self.get_likelihood
    ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"]
  end

  def can_complete? current_user
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == self.responsible_user_id rescue false) ||
      current_user.admin? ||
      current_user.has_access('investigations','admin')
  end

  def can_approve? current_user
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == self.final_approver_id rescue true) ||
      current_user.admin? ||
      current_user.has_access('investigations','admin')
  end

  def can_reopen? current_user
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('investigations','admin'))
  end

  def likelihood_index
    if BaseConfig.airline[:base_risk_matrix]
      self.class.get_likelihood.index(self.likelihood).to_i
    else
      self.likelihood.to_i
    end
    #self.class.get_likelihood.index(self.likelihood).to_i
    # self.likelihood.to_i
  end
  def likelihood_after_index
    if BaseConfig.airline[:base_risk_matrix]
      self.class.get_likelihood.index(self.likelihood_after).to_i
    else
      self.likelihood_after.to_i
    end
    #self.class.get_likelihood.index(self.likelihood_after).to_i
    # self.likelihood_after.to_i
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
