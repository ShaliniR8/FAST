class RiskControl < Srm::SafetyRiskManagementBase
  extend AnalyticsFilters
  include ModelHelpers
  include StandardWorkflow

#Concerns List
  include Attachmentable
  include Commentable
  include Costable
  include Occurrenceable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable

  belongs_to  :created_by,        foreign_key: "created_by_id",         class_name: "User"
  belongs_to  :approver,          foreign_key: 'approver_id',           class_name: 'User'
  belongs_to  :responsible_user,  foreign_key: 'responsible_user_id',   class_name: 'User'
  belongs_to  :hazard,            foreign_key: 'hazard_id'
  has_many    :descriptions,      foreign_key: 'owner_id',              class_name: 'RiskControlDescription',   dependent: :destroy

  accepts_nested_attributes_for :descriptions

  after_create :create_transaction
  after_create :create_owner_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['RiskControl'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['RiskControl'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                                .map { |key, _| key.to_s }

    keys[keys.index('source')] = 'hazard_id' if keys.include? 'source'
    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name' if keys.include? 'responsible_user'
    keys[keys.index('approver')] = 'approver#approver.full_name' if keys.include? 'approver'
    keys[keys.index('verifications')] = 'verifications.status' if keys.include? 'verifications'

    keys
  end


  def get_source
    if self.owner.present?
      "<a style='font-weight:bold' href='/hazards/#{self.hazard_id}'>
        #{Hazard} ##{self.hazard_id}
      </a>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end
  end


  def owner
    self.hazard
  end


  def get_approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def get_due_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
  end


  def type
    "RiskControl"
  end

end
