class Evaluation < Sa::SafetyAssuranceBase
  extend AnalyticsFilters
  include GroupAccessHandling
  include ModelHelpers
  include StandardWorkflow

#Concerns List
  include Attachmentable
  include Commentable
  include Contactable
  include Costable
  include Findingable
  include Occurrenceable
  include Noticeable
  include Signatureable
  include SmsTaskable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable

#Associations List
  belongs_to  :approver,          foreign_key: 'approver_id',             class_name: 'User'
  belongs_to  :responsible_user,  foreign_key: 'responsible_user_id',     class_name: 'User'
  belongs_to  :created_by,        foreign_key: 'created_by_id',           class_name: 'User'

  has_many    :requirements,      foreign_key: 'owner_id',                class_name: 'EvaluationRequirement',    dependent: :destroy
  has_many    :items,             foreign_key: 'owner_id',                class_name: 'EvaluationItem',           dependent: :destroy

  has_many    :checklists, as: :owner, dependent: :destroy


  accepts_nested_attributes_for :requirements
  accepts_nested_attributes_for :items

  after_create :create_transaction
  after_save :delete_cached_fragments

  scope :templates, -> {where(template: 1)}
  scope :regulars, -> {where(template: 0)}

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['Evaluation'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Evaluation'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                          .map { |key, _| key.to_s }

    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name' if keys.include? 'responsible_user'
    keys[keys.index('findings')] = 'findings.id' if keys.include? 'findings'
    keys[keys.index('verifications')] = 'verifications.status' if keys.include? 'verifications'

    keys
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Evaluator',
      30 => 'Admin',
    }
  end


  def clear_checklist
    self.items.each {|x| x.destroy}
  end


  def open_checklist
    self.items.each do |i|
      i.status="Open"
      i.save
    end
  end


  def deletable
      self.status=="New"||self.status=="Scheduled"
  end


  def evaluator_name
    self.responsible_user.present? ?  self.responsible_user.full_name : ""
  end


  def approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def get_completion_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
  end

  def type
    "Inspection"
  end


  def can_complete?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      self.items.all?{ |x| x.status == "Completed" }
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

  def delete_cached_fragments
    fragment_name = "source_evaluations_#{id}"
    ActionController::Base.new.expire_fragment(fragment_name)
  end
end
