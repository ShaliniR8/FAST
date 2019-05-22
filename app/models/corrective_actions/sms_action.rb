class SmsAction < ActiveRecord::Base
  belongs_to  :approver,                foreign_key: "approver_id",               class_name: "User"
  belongs_to  :responsible_user,        foreign_key: "responsible_user_id",       class_name: "User"
  belongs_to  :created_by,              foreign_key: 'created_by_id',             class_name: 'User'
  has_many    :costs,                   foreign_key: "owner_id",                  class_name: "ActionCost",               :dependent => :destroy
  has_many    :transactions,            foreign_key: "owner_id",                  class_name: "SmsActionTransaction",     :dependent => :destroy
  has_many    :attachments,             foreign_key: 'owner_id',                  class_name: 'SmsActionAttachment',      :dependent => :destroy
  has_many    :descriptions,            foreign_key: 'owner_id',                  class_name: 'SmsActionDescription',     :dependent => :destroy
  has_many    :notices,                 foreign_key: "owner_id",                  class_name: "SmsActionNotice",          :dependent => :destroy
  has_many    :verifications,           foreign_key: "owner_id",                  class_name: "SmsActionVerification",    :dependent => :destroy
  has_many    :extension_requests,      foreign_key: "owner_id",                  class_name: "SmsActionExtensionRequest",:dependent => :destroy
  accepts_nested_attributes_for :costs
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank?&&attachment[:_destroy].blank?)}
  after_create -> { create_transaction('Create') }


  after_create    :owner_transaction
  before_create   :set_priveleges
  serialize :privileges
  serialize :severity_extra
  serialize :probability_extra
  serialize :mitigated_severity
  serialize :mitigated_probability

  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                             title: 'ID',                                num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                          title: 'Title',                             num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {field: 'get_status',                     title: 'Status',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'get_source',                     title: 'Source of Input',                   num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},

      {                                                                                                   type: 'newline',      visible: 'show'},
      {field: 'schedule_completion_date',       title: 'Scheduled Completion Date',         num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'responsible_user_id',            title: 'Responsible User',                  num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',                    title: 'Final Approver',                    num_cols: 6,  type: 'user',         visible: 'index,form,show',       required: true},
      {field: 'responsible_department',         title: 'Responsible Department',            num_cols: 6,  type: 'select',       visible: 'form,show', required: false, options: get_custom_options('Departments')},
      {                                                                                                   type: 'newline',      visible: 'form'},
      {field: 'emp',                            title: 'Employee Corrective Action',        num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'dep',                            title: 'Company Corrective Action',         num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {                                                                                                   type: 'newline',      visible: 'form'},
      {field: 'immediate_action',               title: 'Immediate Action',                  num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'immediate_action_comment',       title: 'Immediate Action Comment',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'comprehensive_action',           title: 'Comprehensive Action',              num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'comprehensive_action_comment',   title: 'Comprehensive Action Comment',      num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'action_taken',                   title: 'Action Taken',                      num_cols: 12, type: 'datalist',     visible: 'form,show',       required: false, options: get_custom_options('Actions Taken')},
      {field: 'description',                    title: 'Description of Corrective Action',  num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'sms_actions_comment',            title: 'Corrective Action Comment',         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',                  title: 'Final Comment',                     num_cols: 12, type: 'textarea',     visible: 'show',            required: false},

      {field: 'likelihood',           title: 'Baseline Likelihood',       num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity',             title: 'Baseline Severity',         num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor',          title: 'Baseline Risk',             num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',     title: 'Mitigated Likelihood',      num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity_after',       title: 'Mitigated Severity',        num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor_after',    title: 'Mitigated Risk',            num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_after_risk_color'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_source
    "<b style='color:grey'>N/A</b>".html_safe
  end



  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
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
      self.privileges = []
    end
  end


  def get_status
    verification_needed = self.verifications.select{|x| x.status == 'New'}.length > 0
    extension_requested = self.extension_requests.select{|x| x.status == "New"}.length > 0
    if verification_needed
      "Completed, Verification Required"
    elsif extension_requested
      "#{status}, Extension Requested"
    else
      status
    end
  end


  def create_transaction(action)
    SmsActionTransaction.create(
      :users_id => session[:user_id],
      :action => action,
      :owner_id => self.id,
      :stamp => Time.now)
  end



  def owner_transaction
    if self.type == "FindingAction"
      FindingTransaction.create(
        :users_id => session[:user_id],
        :action => "Add Corrective Action",
        :content => "##{self.get_id} - #{self.title}",
        :owner_id => self.finding.id,
        :stamp => Time.now)
    elsif self.type == "InvestigationAction"
      InvestigationTransaction.create(
        :users_id => session[:user_id],
        :action => "Add Corrective Action",
        :content => "##{self.get_id} - #{self.title}",
        :owner_id => self.investigation.id,
        :stamp => Time.now)
    end
  end



  def approver_name
    self.approver.full_name rescue ''
  end



  def responsible_user_name
    self.responsible_user.full_name rescue ''
  end



  def schedule_date
    self.schedule_completion_date.strftime("%Y-%m-%d") rescue ''
  end



  def overdue
    if self.schedule_completion_date.present?
      self.status != "Completed" && self.schedule_completion_date < Time.now.to_date
    end
    false
  end



  def emp_action
    return emp ? "Yes" : "No"
  end



  def dep_action
    return dep ? "Yes" : "No"
  end



  def im_action
    return immediate_action ? "Yes" : "No"
  end



  def com_action
    return comprehensive_action ? "Yes" : "No"
  end


  def self.get_headers
    [
      { :field => :get_id,                          :title => "ID"                                                                      },
      { :field => :title,                           :title => "Title"                                                                   },
      { :field => :schedule_date,                   :title => "Scheduled Completion Date"                                               },
      { :field => :responsible_user_name,           :title => "Responsible User"                                                        },
      { :field => :responsible_department,          :title =>"Department"                                                               },
      { :field => :display_before_risk_factor,      :title => "Baseline Risk",                    :html_class => :get_before_risk_color },
      { :field => :display_after_risk_factor,       :title => "Mitigated Risk",                   :html_class => :get_after_risk_color  },
      { :field => :status,                          :title => "Status"                                                                  },
    ]
  end



  def get_before_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_before_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index]
        .index(display_before_risk_factor)
    end
  end



  def get_after_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_after_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index]
        .index(display_after_risk_factor)
    end
  end



  def display_before_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity
    else
      get_risk_values[:severity_1] rescue "N/A"
    end
  end



  def display_before_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood
    else
      get_risk_values[:probability_1] rescue "N/A"
    end
  end



  def display_before_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor rescue "N/A"
    else
      get_risk_values[:risk_1] rescue "N/A"
    end
  end



  def display_after_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity_after
    else
      get_risk_values[:severity_2] rescue "N/A"
    end
  end



  def display_after_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood_after
    else
      get_risk_values[:probability_2] rescue "N/A"
    end
  end



  def display_after_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor_after rescue "N/A"
    else
      get_risk_values[:risk_2] rescue "N/A"
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



  def self.get_search_terms
    {
      'Title' => :title,
      'Status'=> :status,
      'Responsible Department' => :responsible_department,
      'Resonsible User' => "responsible_user_name",
      'Employee Corrective Action (Yes/No)' => 'emp_action',
      'Company Correctvie Action (Yes/No)' => 'dep_action',
      'Immediate Action Taken (Yes/No)' => 'im_action',
      'Immediate Action Comment' => :immediate_action_comment,
      'Comprehensive Action' => 'com_action',
      'Comprehensive Action Comment' => :comprehensive_action_comment,
      'Scheduled Completion Date' => 'schedule_date',
      'Final Approver' => 'approver_name',
      'Action' => :action_taken,
      'Description' => :description
    }.sort.to_h
  end



  def self.terms
    {
      :status => {:type => "select", :options => ['New', 'Assigned', 'Completed', 'Pending Approval']},
      :recommendation => {:type => "select", :options => {'Yes' => true,'No' => false}},
      :description => {:type => "text"},
      :responsible_department => {:type => "select", :options => self.departments},
      :action_taken => {:type => "datalist", :options => self.get_actions}
    }
  end



  def self.get_avg_complete
    candidates = self.where("status = ? and complete_date is not ? and created_at is not null",
      "Completed", nil)
    if candidates.present?
      sum = 0
      candidates.map{|x| sum += (x.complete_date - x.created_at.to_date).to_i}
      result = (sum.to_f / candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end



  def set_extra
    if self.severity_extra.blank?
      self.severity_extra = []
    end
    if self.probability_extra.blank?
      self.probability_extra = []
    end
    if self.mitigated_severity.blank?
      self.mitigated_severity = []
    end
    if self.mitigated_probability.blank?
      self.mitigated_probability = []
    end
  end



  def get_extra_severity
    self.severity_extra rescue []
  end



  def get_extra_probability
    self.probability_extra rescue []
  end



  def get_mitigated_probability
    self.mitigated_probability rescue []
  end



  def get_mitigated_severity
    self.mitigated_severity rescue []
  end



  def self.get_likelihood
    ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"]
  end

  def can_assign?
    self.immediate_action || (self.owner.status == 'Completed' rescue true)
  end

  def can_complete?(current_user)
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == self.responsible_user.id rescue false) ||
      current_user.admin? ||
      current_user.has_access('sms_actions','admin')
  end

  def can_approve?(current_user)
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == approver_id rescue true) ||
      current_user.admin? ||
      current_user.has_access('sms_actions','admin')
  end

  def can_reopen?(current_user)
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('sms_actions','admin'))
  end


  def likelihood_index
    if BaseConfig.airline[:base_risk_matrix]
      self.class.get_likelihood.index(self.likelihood).to_i
    else
      self.likelihood.to_i
    end
    #self.class.get_likelihood.index(self.likelihood).to_i
    #self.likelihood.to_i
  end



  def likelihood_after_index
    if BaseConfig.airline[:base_risk_matrix]
      self.class.get_likelihood.index(self.likelihood_after).to_i
    else
      self.likelihood_after.to_i
    end
    #self.class.get_likelihood.index(self.likelihood_after).to_i
    #self.likelihood_after.to_i
  end
end
