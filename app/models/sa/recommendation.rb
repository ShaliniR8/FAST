class Recommendation < Sa::SafetyAssuranceBase
  extend AnalyticsFilters
  include ModelHelpers
  include StandardWorkflow
  include GroupAccessHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Noticeable
  include Occurrenceable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable

#Associations List
  belongs_to :responsible_user,    foreign_key: 'responsible_user_id', class_name: 'User'
  belongs_to :approver,            foreign_key: 'approver_id',         class_name: 'User'
  belongs_to :created_by,          foreign_key: 'created_by_id',       class_name: 'User'
  belongs_to :owner,               polymorphic: true

  has_many :descriptions, foreign_key: 'owner_id', class_name: 'RecommendationDescription', dependent: :destroy

  after_create :create_transaction
  after_create :create_owner_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['Recommendation'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Recommendation'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                                   .map { |key, _| key.to_s }

    keys[keys.index('get_source')] = 'owner_id'
    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name'
    keys[keys.index('verifications')] = 'verifications.address_comment'

    keys
  end


  def get_source
    "<b style='color:grey'>N/A</b>".html_safe
  end


  def can_assign?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      (self.immediate_action || (self.owner.present? && self.owner.status == 'Completed'))
  end

  def get_completion_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
  end

  def get_source
    case owner.class.name
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
end
