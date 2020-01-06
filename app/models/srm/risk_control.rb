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


  def self.get_avg_complete
    candidates=self.where("status=? and date_complete is not ? and date_open is not ?","Completed",nil,nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.date_complete-x.date_open).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


end
