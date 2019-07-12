class Audit < ActiveRecord::Base
  extend AnalyticsFilters
  include StandardWorkflow

#Concerns List
  include Attachmentable
  include Commentable
  include Contactable
  include Costable
  include Findingable
  include Noticeable
  include Signatureable
  include SmsTaskable
  include Transactionable

#Associations List
  belongs_to  :approver,            foreign_key: 'approver_id',           class_name: 'User'
  belongs_to  :responsible_user,    foreign_key: 'responsible_user_id',   class_name: 'User'
  belongs_to  :created_by,          foreign_key: 'created_by_id',         class_name: 'User'
  has_many    :requirements,        foreign_key: 'owner_id',      class_name: 'AuditRequirement',       dependent: :destroy
  has_many    :items,               foreign_key: 'owner_id',      class_name: 'AuditItem',              dependent: :destroy
  has_many    :checklist_records,   foreign_key: 'owner_id',      class_name: 'AuditChecklistRecord',   dependent: :destroy

  has_many    :checklists, as: :owner, dependent: :destroy

  serialize :privileges

  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :requirements
  accepts_nested_attributes_for :checklist_records, :allow_destroy => true
  accepts_nested_attributes_for :checklists

  before_create :set_priveleges
  after_create :create_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',                   title: 'ID',                          num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                title: 'Title',                       num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {                                                                                   type: 'newline',      visible: 'show'},
      {field: 'status',               title: 'Status',                      num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',        title: 'Created By',                  num_cols: 6,  type: 'user',         visible: 'show',            required: false},
      {                                                                                   type: 'newline',      visible: 'show'},
      {field: 'completion',           title: 'Scheduled Completion Date',   num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'responsible_user_id',  title: 'Responsible User',            num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',          title: 'Final Approver',              num_cols: 6,  type: 'user',         visible: 'form,show',       required: false},
      {field: 'department',           title: 'Auditing Department',         num_cols: 6,  type: 'select',       visible: 'index,form,show', required: false,    options: get_custom_options('Departments')},
      {field: 'audit_department',     title: 'Department being Audited',    num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,    options: get_custom_options('Departments')},
      {field: 'audit_type',           title: 'Audit Type',                  num_cols: 6,  type: 'select',       visible: 'index,form,show', required: false,    options: get_custom_options('Audit Types')},
      {field: 'location',             title: 'Location',                    num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'station_code',         title: 'Station Code',                num_cols: 6,  type: 'datalist',     visible: 'form,show',       required: false,    options: get_custom_options('Station Codes')},
      {field: 'vendor',               title: 'Vendor',                      num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'process',              title: 'Process',                     num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'supplier',             title: 'Internal/External/Supplier',  num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,    options: get_custom_options('Suppliers')},
      {field: 'planned',              title: 'Planned',                     num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'objective',            title: 'Objective and Scope',         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'reference',            title: 'References and Requirements', num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'instruction',          title: 'Audit Instructions',          num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'comment',              title: 'Auditor Comment',             num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',        title: 'Final Comment',               num_cols: 12, type: 'textarea',     visible: 'show',            required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Auditor',
      30 => 'Admin',
    }
  end


  def self.progress
    {
      "New"               => { :score => 25,  :color => "default"},
      "Assigned"          => { :score => 50,  :color => "warning"},
      "Pending Approval"  => { :score => 75,  :color => "warning"},
      "Completed"         => { :score => 100, :color => "success"},
    }
  end


  def get_status_score
    self.class.progress[self.status][:score]
  end


  def get_status_color
    self.class.progress[self.status][:color]
  end


  def get_privileges
    self.privileges.present? ? self.privileges : []
  end


  def set_priveleges
    if self.privileges.blank?
      self.privileges=[]
    end
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


  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
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
    self.completion.present? ? self.completion.strftime("%Y-%m-%d") : ""
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


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def can_complete?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      self.items.all?{ |x| x.status == "Completed" }
  end

  def overdue
    self.completion.present? ? self.completion < Time.now.to_date && self.status != "Completed" : false
  end


  def self.get_avg_complete
    candidates = self.where("status = ? and complete_date is not ? and open_date is not ? ", "Completed", nil, nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum += (x.complete_date - x.open_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


end
