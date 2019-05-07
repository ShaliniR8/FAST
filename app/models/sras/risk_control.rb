class RiskControl < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Commentable
  include Transactionable

  belongs_to  :created_by,        foreign_key: "created_by_id",         class_name: "User"
  belongs_to  :approver,          foreign_key: 'approver_id',           class_name: 'User'
  belongs_to  :responsible_user,  foreign_key: 'responsible_user_id',   class_name: 'User'
  belongs_to  :hazard,            foreign_key: 'hazard_id'
  has_many    :costs,             foreign_key: 'owner_id',              class_name: 'ControlCost'
  has_many    :descriptions,      foreign_key: 'owner_id',              class_name: 'RiskControlDescription',   dependent: :destroy
  has_many    :notices,           foreign_key: 'owner_id',              class_name: 'RiskControlNotice',        dependent: :destroy

  accepts_nested_attributes_for :descriptions
  accepts_nested_attributes_for :costs

  after_create -> { create_transaction('Create') }

  extend AnalyticsFilters

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      {field: 'id',                           title: 'ID',                              num_cols: 6,  type: 'text',     visible: 'index,show',      required: false,      editable: false},
      {field: 'status',                       title: 'Status',                          num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: 'title',                        title: 'Title',                           num_cols: 6,  type: 'text',     visible: 'index,form,show', required: true},
      {field: 'scheduled_completion_date',    title: 'Scheduled Completion Date',       num_cols: 6,  type: 'date',     visible: 'index,form,show', required: false},
      {field: 'responsible_user_id',          title: 'Responsible User',                num_cols: 6,  type: 'user',     visible: 'index,form,show', required: false},
      {field: 'approver_id',                  title: 'Final Approver',                  num_cols: 6,  type: 'user',     visible: 'index,form,show', required: false},
      {field: 'follow_up_date',               title: 'Date for Follow-Up/Monitor Plan', num_cols: 6,  type: 'date',     visible: 'form,show',       required: false},
      {field: 'control_type',                 title: 'Type',                            num_cols: 6,  type: 'datalist', visible: 'form,show',       required: false, options: get_custom_options('Risk Control Types')},
      {field: 'description',                  title: 'Description of Hazard',           num_cols: 12, type: 'textarea', visible: 'form,show',       required: false},
      {field: 'notes',                        title: 'Notes',                           num_cols: 12, type: 'textarea', visible: 'form,show',       required: false},
      {field: 'final_comment',                title: 'Final Comment',                   num_cols: 12, type: 'textarea', visible: 'show'},
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




  def create_transaction(action)
    Transaction.build_for(
      self,
      action,
      session[:user_id]
    )
    Transaction.build_for(
      self.hazard,
      'Add Risk Control',
      session[:user_id],
      "##{self.get_id} #{self.title}"
    )
  end

  def release
    if self.status=="New"
      self.status="Open"
      self.save
    end
  end

  def get_approver_name
    self.approver.present? ? self.approver.full_name : ""
  end

  def get_responsible_user_name
    self.responsible_user.present? ? self.responsible_user.full_name : ""
  end

  def get_completion_date
    self.scheduled_completion_date.present? ? self.scheduled_completion_date.strftime("%Y-%m-%d") : ""
  end


  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
  end

  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end

  def can_complete? current_user
    (current_user.id == @risk_control.responsible_user_id rescue true) ||
      current_user.admin? ||
      current_user.has_access('sras','admin')
  end

  def can_approve? current_user
    current_user_id = session[:simulated_id] || session[:user_id]
    self.status == 'Pending Approval' && (current_user_id == self.approver_id ||
      current_user.admin? ||
      current_user.has_access('sras','admin'))
  end

  def can_reopen? current_user
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('sras','admin'))
  end

  def type
    "RiskControl"
  end

  def overdue
    self.scheduled_completion_date.present? ? self.scheduled_completion_date<Time.now.to_date&&self.status!="Completed" : false
  end

  def self.get_avg_complete
    candidates=self.where("status=? and date_complete is not ? and date_open is not ?","Completed",nil,nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.date_complete-x.date_open).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end
end
