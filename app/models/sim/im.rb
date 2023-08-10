class Im < Sim::ImplementationManagementBase
  extend AnalyticsFilters

#Concerns List
  include Attachmentable
  include Contactable
  include Noticeable
  include SmsTaskable
  include Transactionable
  include Noticeable

#Associations List
  belongs_to :evaluator,      foreign_key:"lead_evaluator",   class_name:"User"
  belongs_to :reviewer,       foreign_key:"pre_reviewer",     class_name:"User"
  has_many :expectations,     foreign_key:"owner_id",         class_name:"FrameworkExpectation",  :dependent => :destroy
  has_many :items,            foreign_key:'owner_id',         class_name:"ChecklistItem",         :dependent => :destroy
  has_many :checklists, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :expectations

  after_create :create_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      { field: 'id',                title: 'ID',                          num_cols: 6, type: 'text',      visible: 'index,show',       required: false },
      { field: 'title',             title: 'Title',                       num_cols: 6, type: 'text',      visible: 'index,form,show',  required: true },
      { field: 'completion_date',   title: 'Completion Date',             num_cols: 6, type: 'date',      visible: 'index,form,show',  required: false },
      { field: 'lead_evaluator',    title: 'Lead Evaluator',              num_cols: 6, type: 'user',      visible: 'index,form,show',  required: false },
      { field: 'pre_reviewer',      title: 'Reviewer',                    num_cols: 6, type: 'user',      visible: 'index,form,show',  required: false },
      { field: 'apply_to',          title: 'Plan Applies To',             num_cols: 6, type: 'text',      visible: 'form,show',        required: false },
      { field: 'org_type',          title: 'Organization Type',           num_cols: 6, type: 'text',      visible: 'form,show',        required: false },
      { field: 'obj_scope',         title: 'Objective and Scope',         num_cols: 6, type: 'text',      visible: 'show',             required: false },
      { field: 'ref_req',           title: 'References and Requirements', num_cols: 6, type: 'text',      visible: 'show',             required: false },
      { field: 'instruction',       title: 'Instructions',                num_cols: 6, type: 'text',      visible: 'show',             required: false },
      { field: 'status',            title: 'Status',                      num_cols: 6, type: 'text',      visible: 'index,show',       required: false }
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def completable
    result=true
    self.items.each{|x| result=result&&x.status=="Completed"}
    result
  end


  def self.get_terms
    {
      "Status"=>"status",
      "Lead Evaluator"=>"get_eva",
      "Preliminary Reviewer"=>"get_rev",
      "Scheduled Completion Date"=>"get_completion_date",
      "Location"=>"location",
      "Plan Applied To"=>"apply_to",
      "Organization Type"=>"org_type",
      "Objective and Scope"=>"obj_scope",
      "References and Requirements"=>"ref_req",
      "Instructions"=>"instruction"
    }
  end


  def self.get_apply
    ['Dispatch',
     'FAA',
     'Flight Crew',
     'Flight Operations',
     'Ground',
     'Ground Operations',
     'Human Resources',
     'In-Flight',
     'Maintenance',
     'Quality',
     'Safety',
     'Security',
     'TSA']
  end


  def clear_checklist
    self.items.each {|x| x.destroy}
  end


  def self.get_org
    [
      'Internal Departments',
      'Stakeholders'
    ]
  end


  def self.get_aid
    [
      'Policy Design Validation',
      'SRM Design Validation',
      'SA Design Validation',
      'Promotion Design Validation',
      'Safety Policy Demonstration',
      'Emergency Response Plan Demonstration',
      'Element/Subsys Department Demonstration',
      'SRM System Enterprise Demonstration',
      'Audit Demonstration',
      'Element/Subsys Data Analysis Demonstration',
      'Investigational Process Demonstration',
      'Continuous Improvement Demonstration',
      'Accountable Exec. Resonsibilities Demonstration',
      'Record Retention Demonstration',
      'Safety Communication Demonstration'
    ]
  end


  def self.get_headers
    [
      {:field=>"get_id", :title=>"ID"},
      {:field=>"title" ,:size=>"",:title=>"Title"},
      {:field=>"get_completion_date",:size=>"",:title=>'Scheduled Completion Date'},
      {:field=>"get_eva",:size=>"",:title=>'Lead Evaluator'},
      {:field=>"get_rev",:size=>"",:title=>'Preliminary Reviewer'},
      {:field=>'apply_to',:size=>"",:title=>"Plan Applies To"},
      {:field=>'org_type',:size=>"",:title=>"Organization Type"},
      {:field=>"status",:size=>"",:title=>"Status"}
    ]
  end


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def get_eva
    if self.evaluator.present?
      self.evaluator.full_name
    else
      ""
    end
  end


  def get_rev
    if self.reviewer.present?
      self.reviewer.full_name
    else
      ""
    end
  end


  def get_completion_date
    if self.completion_date.present?
      self.completion_date.strftime("%Y-%m-%d")
    else
      ""
    end
  end


  def overdue
    self.completion_date.present? ? self.completion_date<Time.now.to_date&&self.status!="Completed" : false
  end


  def self.get_avg_complete
    candidates=self.where("status=? and date_complete is not ? and date_open is not ? ","Completed",nil,nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.date_complete-x.date_open).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end

  def open_checklist
    self.items.each do |i|
      i.status="Open"
      i.save
    end
  end

end
