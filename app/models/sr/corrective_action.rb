class CorrectiveAction < ProsafetBase
  extend AnalyticsFilters
  include ModelHelpers

#Concerns List
  include Attachmentable
  include Commentable
  include Transactionable
  include Verifiable
  include ExtensionRequestable

#Associations List
  belongs_to  :report,                foreign_key: 'reports_id',          class_name: 'Report'
  belongs_to  :record,                foreign_key: 'records_id',          class_name: 'Record'
  belongs_to  :submission,            foreign_key: 'submissions_id',      class_name: 'Submission'
  belongs_to  :responsible_user,      foreign_key: 'responsible_user_id', class_name: 'User'
  belongs_to  :approver,              foreign_key: 'approver_id',         class_name: 'User'
  belongs_to  :created_by,            foreign_key: 'created_by_id',       class_name: 'User'

  serialize :privileges
  before_create :set_priveleges
  after_create :create_report_record_transaction
  after_create :create_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['CorrectiveAction'][:fields].values.select{ |f| (f[:visible].split(',') & visible_fields).any? }
  end


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['CorrectiveAction'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                               .map { |key, _| key.to_s }

    keys[keys.index('responsible_user')] = 'responsible_user#responsible_user.full_name' if keys.include? 'responsible_user'
    keys[keys.index('verifications')] = 'verifications.status' if keys.include? 'verifications'

    keys
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

  def self.get_designee
    CONFIG.custom_options['Station Codes']
  end

  def self.get_departments
    CONFIG.custom_options['Departments']
  end

  def self.get_actions
    CONFIG.custom_options['Actions List for Corrective Actions']
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

  def self.get_meeting_headers
    [
      {:field => :due_date,                 :title => "Scheduled Completion Date"},
      {:field => :department,               :title => "Department"},
      {:field => "get_description",         :title => "Description"},
      {:field => :designee,                 :title => "Station"},
      {:field => :action,                   :title => "Action"},
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

end
