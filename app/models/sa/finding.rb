class Finding < Sa::SafetyAssuranceBase
  extend AnalyticsFilters
  include GroupAccessHandling
  include ModelHelpers
  include RiskHandling
  include StandardWorkflow

#Concerns List
  include Attachmentable
  include Commentable
  include Noticeable
  include Recommendationable
  include SmsActionable
  include Transactionable

#Associations List
  belongs_to  :responsible_user,          foreign_key: "responsible_user_id",     class_name: "User"
  belongs_to  :approver,                  foreign_key: "approver_id",             class_name: "User"
  belongs_to  :created_by,                foreign_key: 'created_by_id',           class_name: 'User'
  belongs_to  :owner,                     polymorphic: true
  has_many    :causes,                    foreign_key: "owner_id",                class_name: "FindingCause",             :dependent => :destroy
  has_many    :descriptions,              foreign_key: "owner_id",                class_name: "FindingDescription",       :dependent => :destroy

  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :descriptions

  after_create    :create_transaction
  after_create    :create_owner_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                         title: 'ID',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                      title: 'Title',                         num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'status',                     title: 'Status',                        num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'get_source',                 title: 'Source of Input',               num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'created_by_id',              title: 'Created By',                    num_cols: 6,  type: 'user',         visible: 'show',            required: false},

      {field: 'responsible_user_id',        title: 'Responsible User',              num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',                title: 'Final Approver',                num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
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

      {field: 'likelihood',                 title: 'Baseline Likelihood',           num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'severity',                   title: 'Baseline Severity',             num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'risk_factor',                title: 'Baseline Risk',                 num_cols: 12, type: 'text',         visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',           title: 'Mitigated Likelihood',          num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'severity_after',             title: 'Mitigated Severity',            num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'risk_factor_after',          title: 'Mitigated Risk',                num_cols: 12, type: 'text',         visible: 'index',           required: false,  html_class: 'get_after_risk_color'},

    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_source
    "<b style='color:grey'>N/A</b>".html_safe
  end


  def get_owner
    "#{self.owner_type.underscore}s"
  end


  def get_type
    type.titleize
  end


  def get_approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def get_completion_date
    self.completion_date.present? ? self.completion_date.strftime("%Y-%m-%d") : ""
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


  def can_assign?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      (self.immediate_action || self.owner.status == 'Completed')
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
