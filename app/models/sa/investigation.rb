class Investigation < Sa::SafetyAssuranceBase
  extend AnalyticsFilters
  include GroupAccessHandling
  include ModelHelpers
  include StandardWorkflow
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Contactable
  include Costable
  include Findingable
  include Noticeable
  include Occurrenceable
  include Recommendationable
  include Signatureable
  include SmsActionable
  include SmsTaskable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable
  include RootCausable

#Associations List
  belongs_to :owner,                    polymorphic: true
  belongs_to :responsible_user,         :foreign_key => "responsible_user_id",  :class_name => "User"
  belongs_to :approver,                 :foreign_key => "approver_id",          :class_name => "User"
  belongs_to :created_by,               foreign_key: 'created_by_id',           class_name: 'User'
  has_many :causes,                     :foreign_key => "owner_id",             :class_name => "InvestigationCause",            :dependent => :destroy
  has_many :descriptions,               :foreign_key => "owner_id",             :class_name => "InvestigationDescription",      :dependent => :destroy

  has_many    :checklists, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :descriptions

  after_create :create_transaction

  scope :templates, -> {where(template: 1)}
  scope :regulars, -> {where(template: 0)}

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    CONFIG.object['Investigation'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Investigation'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                                  .map { |key, _| key.to_s }

    keys[keys.index('responsible_user')] = 'responsible_user_id' # TODO: connect User table to get full name
    keys[keys.index('verifications')] = 'verifications.address_comment'

    keys
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Investigator',
      30 => 'Admin',
    }
  end


  def get_source
    if self.owner.present?
      "<a style='font-weight:bold' href='/#{owner_type.downcase.pluralize}/#{self.owner_id}'>
        #{owner_titleize} ##{self.owner_id}
      </a>".html_safe
    elsif self.get_parent.present?
      obejct_name =
        if CONFIG::OBJECT_NAME_MAP[self.get_parent.class.name].present?
          CONFIG::OBJECT_NAME_MAP[self.get_parent.class.name]
        else
          self.get_parent.class.name
        end
      "<a style='font-weight:bold' href='/#{self.get_parent.class.name.underscore.pluralize}/#{self.get_parent.id}'>
        #{obejct_name} ##{self.get_parent.id}
      </a>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end
  end

  def owner_titleize
    case owner_type
    when 'Record'
      'Report'
    when 'Report'
      'Event'
    else
      owner_type.titleize
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


  def get_completion_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
  end


  def type
    return "Investigation"
  end

  def included_findings
    result = ""
    self.findings.each do |finding|
      result += "
        <a style='font-weight:bold' href='/findings/#{finding.id}'>
          ##{finding.id}
        </a><br>"
    end

    self.checklists.each do |checklist|
      checklist.checklist_rows.each do |checklist_row|
        checklist_row.findings. each do |finding|
          result += "
            <a style='font-weight:bold' href='/findings/#{finding.id}'>
              ##{finding.id}
            </a><br>"
        end
      end
    end

    result.html_safe
  end

end
