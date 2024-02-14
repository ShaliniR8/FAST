class Sra < Srm::SafetyRiskManagementBase
  extend AnalyticsFilters
  include StandardWorkflow
  include ModelHelpers
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Noticeable
  include Occurrenceable
  include Transactionable
  include ExtensionRequestable
  include Verifiable
  include Contactable
  include SmsTaskable
  include Costable
  include Childable
  include Parentable

#Association List
  has_many :hazards,                  :foreign_key => "sra_id",     :class_name => "Hazard",              :dependent => :destroy
  has_many :srm_agendas,              :foreign_key => "event_id",   :class_name => "SrmAgenda",           :dependent => :destroy
  has_many :sections,                 :foreign_key => "owner_id",   :class_name => "SraSection",          :dependent => :destroy


  has_one :matrix_connection,         :foreign_key => "owner_id",   :class_name => "SraMatrixConnection", :dependent => :destroy
  belongs_to :created_by,             :foreign_key => "created_by_id",          :class_name => "User"
  belongs_to :approver,               :foreign_key => "approver_id",            :class_name => "User"
  belongs_to :reviewer,               :foreign_key => "reviewer_id",            :class_name => "User"
  belongs_to :responsible_user,       :foreign_key => "responsible_user_id",    :class_name => "User"
  belongs_to :meeting,                :foreign_key => "meeting_id",   :class_name => "SrmMeeting"
  belongs_to :owner,                  polymorphic: true

  serialize :departments
  serialize :manuals
  serialize :programs
  serialize :compliances

  accepts_nested_attributes_for :hazards

  after_create :create_transaction
  after_save :delete_cached_fragments


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['Sra'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Sra'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                        .map { |key, _| key.to_s }

    keys[keys.index('source')] = 'owner_id' if keys.include? 'source'
    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name' if keys.include? 'responsible_user'
    keys[keys.index('verifications')] = 'verifications.status' if keys.include? 'verifications'

    keys
  end


  def self.progress
  {
    'New'               => { :score => 15,  :color => 'default'},
    'Assigned'          => { :score => 35,  :color => 'warning'},
    'Pending Review'    => { :score => 60,  :color => 'warning'},
    'Pending Approval'  => { :score => 75,  :color => 'warning'},
    'Completed'         => { :score => 100, :color => 'success'},
  }
end

  def get_source
    if self.owner.present?
      "<a style='font-weight:bold' href='/#{owner_type.downcase.pluralize}/#{self.owner_id}'>
        #{self.owner_titleize} ##{self.owner_id}
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


  def approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def get_due_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
  end

  def can_approve?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) || (
      self.status == 'Pending Review' && ( self.reviewer_id == user.id || has_admin_rights?(user) )
    )
  end


  def delete_cached_fragments
    source_fragment_name = "source_sras_#{id}"
    show_fragment_name = "show_sras_#{id}"

    ActionController::Base.new.expire_fragment(source_fragment_name)
    ActionController::Base.new.expire_fragment(show_fragment_name)
  end

  def has_show_access(user)
    related_user_ids = []
    related_user_ids << self.created_by_id
    if self.responsible_user_id.present?
      related_user_ids << self.responsible_user_id
    end
    if self.reviewer_id.present?
      related_user_ids << self.reviewer_id
    end
    if self.approver_id.present?
      related_user_ids << self.approver_id
    end
    if self.tasks.present?
      self.tasks.each do |t|
        if t.res.present?
          related_user_ids << t.res
        end
        if t.app_id.present?
          related_user_ids << t.app_id
        end
      end
    end


    has_access = false
    if user.has_access('sras', 'viewer', admin: CONFIG::GENERAL[:global_admin_default]) && self.viewer_access.present?
      has_access = true
    else
      has_access = user.has_access('sras', 'show', admin: CONFIG::GENERAL[:global_admin_default]) &&
                   (related_user_ids.include?(user.id) ||
                   user.has_access('sras', 'admin', admin: CONFIG::GENERAL[:global_admin_default]))
    end
    has_access
  end

end
