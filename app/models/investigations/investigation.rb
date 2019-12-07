class Investigation < ActiveRecord::Base
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
  include Recommendationable
  include Signatureable
  include SmsActionable
  include SmsTaskable
  include Transactionable

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
    [
      {field: 'id',                         title: 'ID',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                      title: 'Title',                         num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {field: 'get_source',                 title: 'Source of Input',               num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'status',                     title: 'Status',                        num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',              title: 'Created By',                    num_cols: 6,  type: 'user',         visible: 'show',            required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'viewer_access',              title: 'Viewer Access',                 num_cols: 6,  type: 'boolean_box',  visible: 'show',            required: false},
      {                                                                                           type: 'newline',      visible: 'show'},
      {field: 'completion',                 title: 'Scheduled Completion Date',     num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'close_date',                 title: 'Actual Completion Date',        num_cols: 6,  type: 'date',         visible: 'index,show',      required: false},
      {field: 'responsible_user_id',        title: 'Investigator',                  num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',                title: 'Final Approver',                num_cols: 6,  type: 'user',         visible: 'form,show',       required: false},
      {field: 'event_occured',              title: 'Date/Time When Event Occurred', num_cols: 6,  type: 'datetime',     visible: 'form,show',       required: false},
      {field: 'local_event_occured',        title: 'Local Time When Event Occurred',num_cols: 6,  type: 'datetime',     visible: 'form,show',       required: false},
      {field: 'inv_type',                   title: 'Investigation Type',            num_cols: 6,  type: 'datalist',     visible: 'index,form,show', required: false,    options: get_custom_options('Investigation Types')},
      {field: 'source',                     title: 'Source',                        num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,    options: get_custom_options('Sources')},
      {field: 'ntsb',                       title: 'NTSB Reportable',               num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'safety_hazard',              title: 'Safety Hazard',                 num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'containment',                title: 'Containment',                   num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'notes',                      title: 'Notes',                         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'description',                title: 'Description of Event',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'investigator_comment',       title: 'Investigator Comment',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',              title: 'Final Comment',                 num_cols: 12, type: 'text',         visible: 'show',            required: false},

      {field: 'likelihood',                 title: "#{I18n.t("sa.risk.baseline.title")} Likelihood",       num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity',                   title: "#{I18n.t("sa.risk.baseline.title")} Severity",         num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor',                title: "#{I18n.t("sa.risk.baseline.title")} Risk",             num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',           title: "#{I18n.t("sa.risk.mitigated.title")} Likelihood",      num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity_after',             title: "#{I18n.t("sa.risk.mitigated.title")} Severity",        num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor_after',          title: "#{I18n.t("sa.risk.mitigated.title")} Risk",            num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_after_risk_color'},

    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
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
    self.completion.present? ? self.completion.strftime("%Y-%m-%d") : ""
  end


  def type
    return "Investigation"
  end


  def self.get_avg_complete
    candidates=self.where("status=? and complete_date is not ?","Completed",nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.complete_date-x.created_at.to_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


end
