class Evaluation < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Commentable
  include Contactable
  include Costable
  include Findingable
  include Signatureable
  include SmsTaskable
  include Transactionable

#Associations List
  belongs_to  :approver,          foreign_key: 'approver_id',             class_name: 'User'
  belongs_to  :responsible_user,  foreign_key: 'responsible_user_id',     class_name: 'User'
  belongs_to  :created_by,        foreign_key: 'created_by_id',           class_name: 'User'

  has_many    :requirements,      foreign_key: 'owner_id',                class_name: 'EvaluationRequirement',    dependent: :destroy
  has_many    :items,             foreign_key: 'owner_id',                class_name: 'EvaluationItem',           dependent: :destroy
  has_many    :notices,           foreign_key: 'owner_id',                class_name: 'EvaluationNotice',         dependent: :destroy

  has_many    :checklists, as: :owner, dependent: :destroy


  accepts_nested_attributes_for :requirements
  accepts_nested_attributes_for :items
  after_create -> { create_transaction('Create') }
  # after_update -> { create_transaction('Edit') }

  before_create :set_priveleges
  serialize :privileges

  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',                       title: 'ID',                          num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'title',                    title: 'Title',                       num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {                                                                                       type: 'newline',      visible: 'show'},
      {field: 'status',                   title: 'Status',                      num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',           title: 'Created By',                  num_cols: 6,  type: 'user',         visible: 'show',            required: false},

      {                                                                                       type: 'newline',      visible: 'show'},
      {field: 'viewer_access',            title: 'Viewer Access',               num_cols: 6,  type: 'boolean_box',  visible: 'show',            required: false},
      {                                                                                       type: 'newline',      visible: 'show'},
      {field: 'completion',               title: 'Scheduled Completion Date',   num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {field: 'responsible_user_id',      title: 'Lead Evaluator',              num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      {field: 'approver_id',              title: 'Final Approver',              num_cols: 6,  type: 'user',         visible: 'form,show',       required: false},
      {field: 'department',               title: 'Evaluation Department',       num_cols: 6,  type: 'select',       visible: 'index,form,show', required: false,      options: get_custom_options('Departments')},
      {field: 'evaluation_department',    title: 'Department being Evaluated',  num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,      options: get_custom_options('Departments')},
      {field: 'evaluation_type',          title: 'Type',                        num_cols: 6,  type: 'datalist',     visible: 'index,form,show', required: false,      options: get_custom_options('Evaluation Types')},
      {field: 'location',                 title: 'Location',                    num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'station_code',             title: 'Station Code',                num_cols: 6,  type: 'datalist',     visible: 'form,show',       required: false,      options: get_custom_options('Station Codes')},
      {field: 'vendor',                   title: 'Vendor',                      num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'process',                  title: 'Process',                     num_cols: 6,  type: 'text',         visible: 'form,show',       required: false},
      {field: 'supplier',                 title: 'Internal/External/Supplier',  num_cols: 6,  type: 'select',       visible: 'form,show',       required: false,      options: get_custom_options('Suppliers')},
      {field: 'planned',                  title: 'Planned',                     num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {field: 'objective',                title: 'Objective and Scope',         num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'reference',                title: 'References and Requirements', num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'instruction',              title: 'Evaluation Instructions',     num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'evaluator_comment',        title: 'Evaluator Comment',           num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      {field: 'final_comment',            title: 'Final Comment',               num_cols: 12, type: 'textarea',     visible: 'show',            required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
  end


  def self.user_levels
    {
      0  => 'N/A',
      10 => 'Viewer',
      20 => 'Evaluator',
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

  def get_privileges
    self.privileges.present? ?  self.privileges : []
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
    self.completion.present? ? self.completion.strftime("%Y-%m-%d") : ""
  end

  def type
    "Inspection"
  end

  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end

  def overdue
    self.completion.present? ? self.completion<Time.now.to_date&&self.status!="Completed" : false
  end

  def get_planned
    return planned ? "Yes" : "No"
  end


  def can_complete?(current_user)
    current_user_id = session[:simulated_id] || session[:user_id]
    result = (current_user_id == self.responsible_user_id rescue false) ||
      current_user.admin? ||
      current_user.has_access('evaluations','admin')
    self.items.each{|x| result=result&&x.status=="Completed"}
    result
  end

  def can_approve?(current_user)
    current_user_id = session[:simulated_id] || session[:user_id]
    (current_user_id == self.approver.id rescue true) ||
      current_user.admin? ||
      current_user.has_access('evaluations','admin')
  end

  def can_reopen?(current_user)
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('evaluations','admin'))
  end



  def self.get_terms
    {
      "Title"                         =>  :title,
      "Status"                        =>  "status",
      "Lead Evaluator"                =>  "Evaluator_name",
      "Final Approver"                =>  "approver_name",
      "Evaluation Department"         =>  :department,
      "Department Being Evaluated"    =>  :evaluation_department,
      "Scheduled Completion Date"     =>  "get_completion_date",
      "Vendor"                        =>  "vendor",
      "Type"                          =>  "evaluation_type",
      "Supplier"                      =>  "supplier",
      "Location"                      =>  "location",
      "Station Code"                  =>  "station_code",
      "Process"                       =>  "process",
      "Planned"                       =>  "get_planned",
      "Internal/External/Supplier"    =>  "supplier",
      "Objective and Scope"           =>  "objective",
      "References and Requirements"   =>  "reference",
      "Evaluation Instructions"       =>  "instruction"
    }.sort.to_h
  end


  def self.get_avg_complete
    candidates=self.where("status=? and complete_date is not ? and open_date is not ? ","Completed",nil,nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.complete_date-x.open_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end
end
