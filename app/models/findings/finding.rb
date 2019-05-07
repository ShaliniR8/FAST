class Finding < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Recommendationable
  include Transactionable

#Associations List
  belongs_to  :responsible_user,          foreign_key: "responsible_user_id",     class_name: "User"
  belongs_to  :approver,                  foreign_key: "approver_id",             class_name: "User"
  belongs_to  :created_by,                foreign_key: 'created_by_id',           class_name: 'User'
  belongs_to  :owner,                     polymorphic: true
  has_many    :causes,                    foreign_key: "owner_id",                class_name: "FindingCause",             :dependent => :destroy
  has_many    :descriptions,              foreign_key: "owner_id",                class_name: "FindingDescription",       :dependent => :destroy
  has_many    :corrective_actions,        foreign_key: "owner_id",                class_name: "FindingAction",            :dependent => :destroy
  has_many    :comments,                  foreign_key: "owner_id",                class_name: "FindingComment",           :dependent => :destroy
  has_many    :notices,                   foreign_key: "owner_id",                class_name: "FindingNotice",            :dependent => :destroy

  accepts_nested_attributes_for :corrective_actions
  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :descriptions
  accepts_nested_attributes_for :comments

  after_create    :create_finding_transaction
  before_create   :set_priveleges
  serialize       :privileges
  serialize       :severity_extra
  serialize       :probability_extra
  serialize       :mitigated_severity
  serialize       :mitigated_probability
  before_create   :set_extra

  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                         title: 'ID',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                      title: 'Title',                         num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'status',                     title: 'Status',                        num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'get_source',                 title: 'Source of Input',               num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'responsible_user_id',        title: 'Responsible User',              num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',                title: 'Final Approver',                num_cols: 6,  type: 'user',         visible: 'index,form,show',       required: false},
      {field: 'completion_date',            title: 'Scheduled Completion Date',     num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'reference',                  title: 'Reference or Requirement',      num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'regulatory_violation',       title: 'Regulatory Violation',          num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'policy_violation',           title: 'Policy Violation',              num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'safety',                     title: 'Safety Hazard',                 num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'repeat',                     title: 'Repeat Finding',                num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'authority',                  title: 'Authority',                     num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'controls',                   title: 'Controls',                      num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       rqeuired: false},
      {field: 'interfaces',                 title: 'Interfaces',                    num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'policy',                     title: 'Policy',                        num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'procedures',                 title: 'Procedure',                     num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'process_measures',           title: 'Process Measures',              num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'responsibility',             title: 'Responsibility',                num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {                                                                                           type: 'newline',      visible: 'form'},
      {field: 'classification',             title: 'Classification',                num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,  options: get_custom_options('Classifications')},
      {field: 'department',                 title: 'Department',                    num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,  options: get_custom_options('Departments')},
      {field: 'immediate_action',           title: 'Immediate Action Required',     num_cols: 12, type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'action_taken',               title: 'Immediate Action Taken',        num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'description',                title: 'Description of Finding',        num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'analysis_result',            title: 'Analysis Results',              num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'findings_comment',           title: 'Finding Comment',               num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'other',                      title: 'Other',                         num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
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

  def get_source
    "<b style='color:grey'>N/A</b>".html_safe
  end

  def self.progress
    {
      "New"               => { :score => 25,  :color => "default"},
      "Assigned"          => { :score => 50,  :color => "warning"},
      "Pending Approval"  => { :score => 75,  :color => "warning"},
      "Completed"         => { :score => 100, :color => "success"},
    }
  end



  def get_type
    type.titleize
  end


  def get_privileges
    self.privileges.present? ?  self.privileges : []
  end

  def set_priveleges
    if self.privileges.blank?
      self.privileges = []
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
    self.severity_extra.present? ? self.severity_extra : []
  end

  def get_extra_probability
    self.probability_extra.present? ? self.probability_extra : []
  end
  def get_mitigated_probability
    self.mitigated_probability.present? ? self.mitigated_probability : []
  end
  def get_mitigated_severity
    self.mitigated_severity.present? ? self.mitigated_severity : []
  end


  def create_finding_transaction
    Transaction.build_for(
      self,
      'Create',
      session[:user_id]
    )
    Transaction.build_for( #TODO: Ensure Polymorphism for Findings works here
      self.owner,
      'Add Finding',
      (session[:simulated_id] || session[:user_id]),
      "##{self.get_id} #{self.title}"
    )
  end


  def create_transaction(action)
    Transaction.build_for(
      self,
      action,
      (session[:simulated_id] || session[:user_id])
    )
  end

  def get_approver_name
    self.approver.present? ? self.approver.full_name : ""
  end

  def get_completion_date
    self.completion_date.present? ? self.completion_date.strftime("%Y-%m-%d") : ""
  end

  def overdue
    self.completion_date.present? ? self.completion_date < Time.now.to_date && self.status != "Completed" : false
  end

  def get_responsible_user_name
    self.responsible_user.present? ? self.responsible_user.full_name : ""
  end


  def self.get_yesno
    ['Yes', 'No']
  end

  def self.get_headers
    [
      { :field => :get_id,                              :title => "ID"                                                                        },
      { :field => :title,                               :title => "Title"                                                                     },
      { :field => :get_completion_date,                 :title => "Scheduled Completion Date"                                                 },
      { :field => :get_responsible_user_name,           :title => "Responsible User"                                                          },
      { :field => :get_owner,                           :title => "Association"                                                               },
      { :field => :display_before_risk_factor,          :title => "Baseline Risk",                    :html_class => :get_before_risk_color   },
      { :field => :display_after_risk_factor,           :title => "Mitigated Risk",                   :html_class => :get_after_risk_color    },
      { :field => :status,                              :title => "Status"                                                                    },
    ]
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

  def get_owner
    self.type.gsub("Finding","")
  end

  def self.get_likelihood
    ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"]
  end



  def can_assign?
    self.immediate_action || self.owner.status == 'Completed'
  end

  def can_complete?
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == self.responsible_user.id rescue false) ||
      current_user.admin? ||
      current_user.has_access('findings','admin')
  end

  def can_approve?
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == self.approver.id rescue true) ||
      current_user.admin? ||
      current_user.has_access('findings','admin')
  end

  def can_reopen?(current_user)
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('findings','admin'))
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



  def self.get_terms
    {
      "Status" => "status",
      "Responsible User" => "get_responsible_user_name",
      "Final Approver" => "get_approver_name",
      "Scheduled Completion Date" => "get_completion_date",
      "Severity" => "severity",
      "Likelihood" => "likelihood",
      "Risk Factor" => "risk_factor",
      "Descrption of Finding" => "description",
      "Classification" => "classification",
      "Reference or Requirement" => "reference",
      "Likelihood (Mitigated)" => "likelihood_after",
      "Severity (Mitigated)" => "severity_after",
      "Risk Factor (Mitigated)" => "risk_factor_after"
    }.sort.to_h
  end

  def self.get_avg_complete
    candidates = self.where("status=? and complete_date is not ? and open_date is not ? ","Completed", nil, nil)
    if candidates.present?
      sum = 0
      candidates.map{|x| sum += (x.complete_date - x.open_date).to_i}
      result = (sum.to_f / candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end

  def get_source
    case owner.class.name
    when 'Audit'
      "<a style='font-weight:bold' href='/audits/#{owner.id}'>
        Audit ##{owner.id}
      </a>".html_safe
    when 'Inspection'
      "<a style='font-weight:bold' href='/inspections/#{owner.id}'>
        Inspection ##{owner.id}
      </a>".html_safe
    when 'Evaluation'
      "<a style='font-weight:bold' href='/evaluations/#{owner.id}'>
        Evaluation ##{owner.id}
      </a>".html_safe
    when 'Investigation'
      "<a style='font-weight:bold' href='/investigations/#{owner.id}'>
        Investigation ##{owner.id}
      </a>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end

  end



end
