class CorrectiveAction < ActiveRecord::Base
  belongs_to  :report,                foreign_key: 'reports_id',          class_name: 'Report'
  belongs_to  :record,                foreign_key: 'records_id',          class_name: 'Record'
  belongs_to  :responsible_user,      foreign_key: 'responsible_user_id', class_name: 'User'
  belongs_to  :approver,              foreign_key: 'approver_id',         class_name: 'User'
  belongs_to  :created_by,            foreign_key: 'created_by_id',       class_name: 'User'

  has_many :attachments,    foreign_key: 'owner_id',  class_name: 'CorrectiveActionAttachment',   dependent: :destroy
  has_many :transactions,   as: :owner,   dependent: :destroy
  has_many :notices,        foreign_key: 'owner_id',  class_name: 'CorrectiveActionNotice',       dependent: :destroy

  accepts_nested_attributes_for :attachments,
    allow_destroy: true,
    reject_if: Proc.new{|attachment| (attachment[:name].blank? && attachment[:_destroy].blank?)}

  after_create -> { create_transaction('Create') }
  # after_update -> { create_transaction('Edit') }

  after_create :create_report_record_transaction
  serialize :privileges
  before_create :set_priveleges


  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: 'id',                      title: 'ID',                                    num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      { field: 'status',                  title: 'Status',                                num_cols: 6,  type: 'select',   visible: 'index,show',      required: false, options: getStatusOptions},
      { field: 'recommendation',          title: 'Is this only a recommendation',         num_cols: 6,  type: 'boolean',  visible: 'form,show',       required: false},
      { field: 'due_date',                title: 'Scheduled Completion Date',             num_cols: 6,  type: 'date',     visible: 'index,form,show', required: false},
      { field: 'opened_date',             title: 'Date Opened',                           num_cols: 6,  type: 'date',     visible: 'show',            required: false},
      { field: 'assigned_date',           title: 'Date Assigned',                         num_cols: 6,  type: 'date',     visible: 'show',            required: false},
      { field: 'decision_date',           title: 'Date Completed/Rejected',               num_cols: 6,  type: 'date',     visible: 'show',            required: false},
      { field: 'department',              title: 'Department',                            num_cols: 6,  type: 'select',   visible: 'form,show',       required: false, options: departments},
      {                                                                                                 type: 'newline',  visible: 'form,show'},
      { field: 'responsible_user_id',     title: 'Responsible User',                      num_cols: 6,  type: 'user',     visible: 'index,form,show',       required: false},
      { field: 'approver_id',             title: 'Final Approver',                        num_cols: 6,  type: 'user',     visible: 'index,form,show',       required: false},
      {                                                                                                 type: 'newline',  visible: 'form,show'},
      { field: 'bimmediate_action',       title: 'Immediate Action',                      num_cols: 2,  type: 'boolean',  visible: 'form,show',       required: false},
      { field: 'immediate_action',        title: 'Immediate Action',                      num_cols: 10, type: 'text',     visible: 'form,show',       required: false},
      {                                                                                                 type: 'newline',  visible: 'form,show'},
      { field: 'bcomprehensive_action',   title: 'Comprehensive Action',                  num_cols: 2,  type: 'boolean',  visible: 'form,show',       required: false},
      { field: 'comprehensive_action',    title: 'Comprehensive Action',                  num_cols: 10, type: 'text',     visible: 'form,show',       required: false},
      {                                                                                                 type: 'newline',  visible: 'form,show'},
      { field: 'action',                  title: 'Action',                                num_cols: 6,  type: 'datalist', visible: 'index,form,show',       required: false, options: action_options},
      { field: 'description',             title: 'Description',                           num_cols: 12, type: 'textarea', visible: 'index,form,show',       required: false},
      { field: 'response',                title: 'Response',                              num_cols: 12, type: 'textarea', visible: 'form,show',       required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.progress
    {
      "New"               => { :score => 25,  :color => "default"},
      "Assigned"          => { :score => 50,  :color => "warning"},
      "Pending Approval"  => { :score => 75,  :color => "warning"},
      "Completed"         => { :score => 100, :color => "success"},
    }
  end

  def self.getStatusOptions
    ["New", "Open", "Assigned", "Rejected", "Completed"]
  end



  def self.getYesNoOptions
    {
      "Yes" => true,
      "No"  => false,
    }
  end




  def get_privileges
    self.privileges.present? ?  self.privileges : []
  end



  def set_priveleges
    self.privileges=[]
  end



  def create_transaction(action)
    Transaction.build_for(
      self,
      action,
      session[:user_id]
    )
  end



  def create_report_record_transaction()
    if self.record.present?
      Transaction.build_for(
        self.record,
        'Add Corrective Action',
        session[:user_id],
        "##{self.record.get_id}"
      )
    end
    if self.report.present?
      Transaction.build_for(
        self.report,
        'Add Corrective Action',
        session[:user_id],
        "##{self.report.get_id}",
      )
    end
  end



  def self.departments
    [
      "Crew Scheduling","Environmental","Flight Ops-Line",
      "Dispatch",
      "Environmental",
      "Field Service",
      "Flight Ops-Line",
      "Flight Ops-Tech",
      "Flight Ops-Training",
      "Flight Safety",
      "Flight Service",
      "Ground Safety",
      "Hazmat",
      "Maintenance"
    ]
  end



  def self.status_options
    [
      "New",
      "Open",
      "Assigned",
      "Rejected",
      "Completed"
    ]
  end



  def self.action_options
    [
      'ASAP/Safety Update',
      'Coaching',
      'CVR/DFDR Notification',
      'CVR/DFDR Removal',
      'Employee Training',
      'ERC Letter of Correction',
      'ERC Letter of No Action',
      'FAA Letter of Correction',
      'FAA Letter of No Action',
      'FAA Letter of Warning',
      'Foward to Department',
      'Inquiry-Customer Care',
      'LOI Response',
      'Manual Revision',
      'NTSB Notification',
      'Procedure Change',
      'Respond to Employee',
      'Risk Statement',
      'Safety Requested Response',
      'Self Disclosure'
    ]
  end

  def get_description
    if self.description.blank?
      ""
    elsif self.description.length>30
      self.description[0..27]+"..."
    else
      self.description
    end
  end

  def get_response
    if self.response.blank?
      ""
    elsif self.response.length>30
      self.response[0..27]+"..."
    else
      self.response
    end
  end

  def get_opened
    if self.opened_date.present?
      self.opened_date.strftime("%Y-%m-%d")
    else
      ""
    end
  end

  def get_association
    if self.employee
      "Employee"
    else
      "Company"
    end
  end

  def self.get_headers
    [
      {:field => "get_id",                  :title => "ID"},
      {:field => :assigned_date,            :title => "Assigned Date"},
      {:field => :get_responsible_user,     :title => "Assigned To"},
      {:field => :due_date,                 :title => "Schedule Completion Date"},
      {:field => :response,                 :title => "Response"},
      {:field => :get_final_approver,       :title => "Final Approver"},
      {:field => :close_date,               :title => "Completion Date"},
      {:field => :status,                   :title => "Status"},
    ]
  end

  def get_final_approver
    approver.full_name
  end

  def get_responsible_user
    employee_responsible.full_name
  end

  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end

  def self.get_search_terms
    {
      'Status'=> :status,
      'Recommendation'=>:recommendation,
      'Description'=>:description,
      'Department'=>:department,
      'Response'=>:response,
      'Action'=>:action
    }
  end

  def self.terms
    {
      :status=>{ :type =>"select",:options=>self.status_options},
      :recommendation=>{:type=>"select",:options=>{'Yes'=>true,'No'=>false}},
      :description=>{:type=>"text"},
      :department=>{:type=>"select",:options=>self.departments},
      :response=>{:type=>"text"},
      :action=>{:type=>"datalist",:options=>self.action_options}
    }
  end

  def self.get_avg_complete
    candidates = self.where("status = ? and created_at is not ? and close_date is not ?",
      "Completed", nil, nil)
    if candidates.present?
      sum = 0
      candidates.map{|x| sum += (x.close_date - x.created_at.to_date).to_i}
      result = (sum.to_f / candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end
end
