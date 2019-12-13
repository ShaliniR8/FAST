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
  include RootCausable
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
    CONFIG.object['Finding'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
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
