class Audit < Sa::SafetyAssuranceBase
  extend AnalyticsFilters
  include GroupAccessHandling
  include ModelHelpers
  include StandardWorkflow

#Concerns List
  include Attachmentable
  include Commentable
  include Contactable
  include SmsTaskable
  include SmsActionable
  include Costable
  include Findingable
  include Noticeable
  include Occurrenceable
  include Signatureable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable

#Associations List
  belongs_to  :approver,            foreign_key: 'approver_id',           class_name: 'User'
  belongs_to  :responsible_user,    foreign_key: 'responsible_user_id',   class_name: 'User'
  belongs_to  :created_by,          foreign_key: 'created_by_id',         class_name: 'User'
  has_many    :requirements,        foreign_key: 'owner_id',              class_name: 'AuditRequirement',       dependent: :destroy
  has_many    :items,               foreign_key: 'owner_id',              class_name: 'AuditItem',              dependent: :destroy
  has_many    :checklist_records,   foreign_key: 'owner_id',              class_name: 'AuditChecklistRecord',   dependent: :destroy
  has_many    :causes,              foreign_key: 'owner_id',              class_name: 'Cause',                  dependent: :destroy

  has_many    :checklists, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :causes
  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :requirements
  accepts_nested_attributes_for :checklist_records, :allow_destroy => true
  accepts_nested_attributes_for :checklists

  after_create :create_transaction
  after_save :delete_cached_fragments

  scope :templates, -> {where(template: 1)}
  scope :regulars, -> {where(template: 0)}

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['Audit'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Audit'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                          .map { |key, _| key.to_s }

    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name' if keys.include? 'responsible_user'
    keys[keys.index('findings')] = 'findings.id' if keys.include? 'findings'
    keys[keys.index('verifications')] = 'verifications.status' if keys.include? 'verifications'

    keys
  end

  def handle_uniq_custom_id
    current_year = Date.current.year
    last_index = 0

    if Audit.where(template:false).last(2).size == 2 && Audit.where(template:false).last(2).first.uniq_custom_id.present?
      last_year = Audit.where(template:false).last(2).first.uniq_custom_id.split('_').first
      last_index = Audit.where(template:false).last(2).first.uniq_custom_id.split('_').last.to_i if last_year.to_i == current_year.to_i
    end

    self.uniq_custom_id = "#{current_year}_#{last_index+1}" unless self.template
    self.save
  end


  def cause_label
    causes.map { |cause| "#{cause.category.titleize} > #{cause.attr.titleize}".downcase }
  end


  def cause_value
    causes.map { |cause|
      if cause.value == '0'
        'No'
      elsif cause.value == '1'
        'Yes'
      else
        "#{cause.value}".gsub('"','').downcase
      end
    }
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Auditor',
      30 => 'Admin',
    }
  end


  def get_status_score
    self.class.progress[self.status][:score]
  end


  def get_status_color
    self.class.progress[self.status][:color]
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
      self.status == "New" || self.status == "Scheduled" || self.status == "Open"
  end


  def auditor_name
    self.responsible_user.present? ?  self.responsible_user.full_name : ""
  end


  def approver_name
    self.approver.present? ? self.approver.full_name : ""
  end



  def get_completion_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
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


  def type
    "Audit"
  end

  def self.get_headers
    [
      { field: "get_id",                              title: "ID"                         },
      { field: "title" ,                size: "",     title: "Title"                      },
      { field: "get_completion_date",   size: "",     title: 'Scheduled Completion Date'  },
      { field: "auditor_name",          size: "",     title: 'Lead Auditor'               },
      { field: "department",            size: "",     title: "Auditing Department"        },
      { field: "audit_type",            size: "",     title: "Type"                       },
      { field: "status",                size: "",     title: "Status"                     },
    ]
  end


  def can_complete?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      self.items.all?{ |x| x.status == "Completed" }
  end


  def delete_cached_fragments
    fragment_name = "source_audits_#{id}"
    ActionController::Base.new.expire_fragment(fragment_name)
  end


end
