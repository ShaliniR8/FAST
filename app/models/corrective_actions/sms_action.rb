class SmsAction < ActiveRecord::Base
  extend AnalyticsFilters
  include RiskHandling
  include GroupAccessHandling
  include StandardWorkflow

#Concerns List
  include Attachmentable
  include Commentable
  include Costable
  include Noticeable
  include Transactionable

#Associations List
  belongs_to  :approver,                foreign_key: "approver_id",               class_name: "User"
  belongs_to  :responsible_user,        foreign_key: "responsible_user_id",       class_name: "User"
  belongs_to  :created_by,              foreign_key: 'created_by_id',             class_name: 'User'
  belongs_to  :owner,                   polymorphic: true
  has_many    :descriptions,            foreign_key: 'owner_id',                  class_name: 'SmsActionDescription',     :dependent => :destroy
  has_many    :verifications,           foreign_key: "owner_id",                  class_name: "SmsActionVerification",    :dependent => :destroy
  has_many    :extension_requests,      foreign_key: "owner_id",                  class_name: "SmsActionExtensionRequest",:dependent => :destroy

  after_create :create_transaction
  after_create -> { create_owner_transaction(action:'Add Corrective Action') }


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                             title: 'ID',                                num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                          title: 'Title',                             num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {field: 'get_status',                     title: 'Status',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'get_source',                     title: 'Source of Input',                   num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',           title: 'Created By',                  num_cols: 6,  type: 'user',         visible: 'show',            required: false},

      {                                                                                                   type: 'newline',      visible: 'show'},
      {field: 'schedule_completion_date',       title: 'Scheduled Completion Date',         num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'responsible_user_id',            title: 'Responsible User',                  num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',                    title: 'Final Approver',                    num_cols: 6,  type: 'user',         visible: 'index,form,show',       required: true},
      {field: 'responsible_department',         title: 'Responsible Department',            num_cols: 6,  type: 'select',       visible: 'form,show', required: false, options: get_custom_options('Departments')},
      {                                                                                                   type: 'newline',      visible: 'form'},
      {field: 'emp',                            title: 'Employee Corrective Action',        num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'dep',                            title: 'Company Corrective Action',         num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {                                                                                                   type: 'newline',      visible: 'form'},
      {field: 'immediate_action',               title: 'Immediate Action',                  num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'immediate_action_comment',       title: 'Immediate Action Comment',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'comprehensive_action',           title: 'Comprehensive Action',              num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'comprehensive_action_comment',   title: 'Comprehensive Action Comment',      num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'action_taken',                   title: 'Action Taken',                      num_cols: 12, type: 'datalist',     visible: 'form,show',       required: false, options: get_custom_options('Actions Taken')},
      {field: 'description',                    title: 'Description of Corrective Action',  num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'sms_actions_comment',            title: 'Corrective Action Comment',         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',                  title: 'Final Comment',                     num_cols: 12, type: 'textarea',     visible: 'show',            required: false},

      {field: 'likelihood',                     title: 'Baseline Likelihood',               num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'severity',                       title: 'Baseline Severity',                 num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'risk_factor',                    title: 'Baseline Risk',                     num_cols: 12, type: 'text',         visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',               title: 'Mitigated Likelihood',              num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'severity_after',                 title: 'Mitigated Severity',                num_cols: 12, type: 'text',         visible: 'adv',             required: false},
      {field: 'risk_factor_after',              title: 'Mitigated Risk',                    num_cols: 12, type: 'text',         visible: 'index',           required: false,  html_class: 'get_after_risk_color'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
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



  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
  end

  def self.progress
    {
      "New"               => { :score => 25,  :color => "default"},
      "Assigned"          => { :score => 50,  :color => "warning"},
      "Pending Approval"  => { :score => 75,  :color => "warning"},
      "Completed"         => { :score => 100, :color => "success"},
    }
  end


  def get_status
    verification_needed = self.verifications.select{|x| x.status == 'New'}.length > 0
    extension_requested = self.extension_requests.select{|x| x.status == "New"}.length > 0
    if verification_needed
      "Completed, Verification Required"
    elsif extension_requested
      "#{status}, Extension Requested"
    else
      status
    end
  end


  def approver_name
    self.approver.full_name rescue ''
  end


  def responsible_user_name
    self.responsible_user.full_name rescue ''
  end


  def schedule_date
    self.schedule_completion_date.strftime("%Y-%m-%d") rescue ''
  end


  def get_completion_date
    self.schedule_completion_date.strftime("%Y-%m-%d") rescue ''
  end


  def overdue
    if self.schedule_completion_date.present?
      self.status != "Completed" && self.schedule_completion_date < Time.now.to_date
    end
    false
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


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
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
