class SmsAction < Sa::SafetyAssuranceBase
  extend AnalyticsFilters
  include StandardWorkflow
  include GroupAccessHandling
  include ModelHelpers
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Costable
  include Noticeable
  include Occurrenceable
  include Transactionable
  include ExtensionRequestable
  include Verifiable

#Associations List
  belongs_to  :approver,                foreign_key: "approver_id",               class_name: "User"
  belongs_to  :responsible_user,        foreign_key: "responsible_user_id",       class_name: "User"
  belongs_to  :created_by,              foreign_key: 'created_by_id',             class_name: 'User'
  belongs_to  :owner,                   polymorphic: true
  has_many    :descriptions,            foreign_key: 'owner_id',                  class_name: 'SmsActionDescription',     :dependent => :destroy

  after_create :create_transaction
  after_create -> { create_owner_transaction(action:'Add Corrective Action') }


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    CONFIG.object['SmsAction'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_source
    case self.owner_type
    when 'Investigation'
      "<a style='font-weight:bold' href='/investigations/#{owner.id}'>
        Investigation ##{owner.id}
      </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
    when 'Finding'
      "<a style='font-weight:bold' href='/findings/#{owner.id}'>
        Finding ##{owner.id}
      </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end
  end


  def approver_name
    self.approver.full_name rescue ''
  end


  def schedule_date
    self.schedule_completion_date.strftime("%Y-%m-%d") rescue ''
  end


  def get_completion_date
    self.due_date.strftime("%Y-%m-%d") rescue ''
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


  def can_assign?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      (self.immediate_action || (self.owner.status == 'Completed' rescue true))
  end


end
