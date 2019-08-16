class Inspection < ActiveRecord::Base
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
  include Noticeable
  include Signatureable
  include SmsTaskable
  include Transactionable

#Associations List
  belongs_to :approver,             foreign_key: 'approver_id',         class_name: 'User'
  belongs_to :responsible_user,     foreign_key: 'responsible_user_id', class_name: 'User'
  belongs_to :created_by,           foreign_key: 'created_by_id',       class_name: 'User'
  has_many :requirements,           foreign_key: 'owner_id',            class_name: 'InspectionRequirement',    dependent: :destroy
  has_many :items,                  foreign_key: 'owner_id',            class_name: 'InspectionItem',           dependent: :destroy

  has_many :checklists, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :requirements
  accepts_nested_attributes_for :items

  after_create :create_transaction

  scope :templates, -> {where(template: 1)}
  scope :regulars, -> {where(template: 0)}

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',                       title: 'ID',                          num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                    title: 'Title',                       num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {                                                                                       type: 'newline',      visible: 'show'},
      {field: 'status',                   title: 'Status',                      num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',           title: 'Created By',                   num_cols: 6,  type: 'user',         visible: 'show',            required: false},

      {                                                                                       type: 'newline',      visible: 'show'},
      {field: 'viewer_access',            title: 'Viewer Access',               num_cols: 6,  type: 'boolean_box',  visible: 'show',            required: false},
      {                                                                                       type: 'newline',      visible: 'show'},
      {field: 'completion',               title: 'Scheduled Completion Date',   num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'close_date',               title: 'Actual Completion Date',      num_cols: 6,  type: 'date',         visible: 'index,show',      required: false},
      {field: 'responsible_user_id',      title: 'Lead Inspector',              num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',              title: 'Final Approver',              num_cols: 6,  type: 'user',         visible: 'form,show',       required: false},
      {field: 'department',               title: 'Inspection Department',       num_cols: 6,  type: 'select',       visible: 'index,form,show', required: false,      options: get_custom_options('Departments')},
      {field: 'inspection_department',    title: 'Department being Inspected',  num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,      options: get_custom_options('Departments')},
      {field: 'planned',                  title: 'Planned',                     num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {                                                                                       type: 'newline',      visible: 'form,show'},
      {field: 'inspection_type',          title: 'Type',                        num_cols: 6,  type: 'text',         visible: 'index,form,show', required: false},
      {field: 'location',                 title: 'Location',                    num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'station_code',             title: 'Station Code',                num_cols: 6,  type: 'datalist',     visible: 'form,show',       required: false,      options: get_custom_options('Station Codes')},
      {field: 'vendor',                   title: 'Vendor',                      num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'process',                  title: 'Process',                     num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'supplier',                 title: 'Internal/External/Supplier',  num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,      options: get_custom_options('Suppliers')},
      {field: 'objective',                title: 'Objective and Scope',         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'reference',                title: 'References and Requirements', num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'instruction',              title: 'Inspection Instructions',     num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'inspector_comment',        title: 'Inspector Comment',           num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',            title: 'Final Comment',               num_cols: 12, type: 'textarea',     visible: 'show',            required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Inspector',
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
      self.status=="New"||self.status=="Scheduled" || self.status=="Open"
  end


  def inspector_name
    self.responsible_user.present? ?  self.responsible_user.full_name : ""
  end


  def approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def get_completion_date
    self.completion.present? ? self.completion.strftime("%Y-%m-%d") : ""
  end


  def can_complete?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      self.items.all?{ |x| x.status == 'Completed' }
  end


end
