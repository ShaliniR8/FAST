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
  include Occurrenceable
  include Recommendationable
  include RootCausable
  include SmsActionable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable

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


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Finding'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                            .map { |key, _| key.to_s }

    keys[keys.index('get_source')] = 'owner_id'
    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name'
    keys[keys.index('approver')] = 'approver#approver.full_name'
    keys[keys.index('occurrences')] = 'occurrences.value'
    keys[keys.index('verifications')] = 'verifications.status'

    keys
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
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
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
    when 'ChecklistRow'
      true_owner = self.find_true_owner
      true_owner_table_name = true_owner.class.name.underscore.pluralize
      checklist_title = true_owner.checklists[0].title
      checklist_num = @owner.checklist_cells[0].value


      "<a style='font-weight:bold' href='/#{true_owner_table_name}/#{true_owner.id}'>
        #{true_owner.class.name} ##{true_owner.id} > Checklist (#{checklist_title} - ##{checklist_num})
      </a>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end
  end

  def find_true_owner
    if self.owner.class.name == "ChecklistRow"
      checklist_id = self.owner.checklist_id
      checklist = Checklist.find(checklist_id)
      Object.const_get(checklist.owner_type).find(checklist.owner_id)
    else
      nil
    end
  end

end
