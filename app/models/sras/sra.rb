class Sra < ActiveRecord::Base
  extend AnalyticsFilters
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Noticeable
  include Transactionable

#Association List
  has_many :hazards,                  :foreign_key => "sra_id",     :class_name => "Hazard",              :dependent => :destroy
  has_many :srm_agendas,              :foreign_key => "event_id",   :class_name => "SrmAgenda",           :dependent => :destroy
  has_many :responsible_users,        :foreign_key => "owner_id",   :class_name => "SraResponsibleUser",  :dependent => :destroy
  has_many :sections,                 :foreign_key => "owner_id",   :class_name => "SraSection",          :dependent => :destroy


  has_one :matrix_connection,         :foreign_key => "owner_id",   :class_name => "SraMatrixConnection", :dependent => :destroy

  belongs_to :created_by,             :foreign_key => "created_by_id",          :class_name => "User"
  belongs_to :approver,               :foreign_key => "approver_id",            :class_name => "User"
  belongs_to :reviewer,               :foreign_key => "reviewer_id",            :class_name => "User"
  belongs_to :responsible_user,       :foreign_key => "responsible_user_id",    :class_name => "User"
  belongs_to :meeting,                :foreign_key => "meeting_id",   :class_name => "SrmMeeting"
  belongs_to :record,                 :foreign_key => "record_id",    :class_name => "Record"

  serialize :departments
  serialize :manuals
  serialize :programs
  serialize :compliances

  accepts_nested_attributes_for :hazards

  after_create -> { create_transaction('Create') }



  def self.progress
    {
      "New"                     => { :score => 0,   :color => "default"},
      "Assigned"                => { :score => 25,  :color => "default"},
      "Pending Review"          => { :score => 50,  :color => "warning"},
      "Pending Approval"        => { :score => 75,  :color => "warning"},
      "Completed"               => { :score => 100, :color => "success"},
    }
  end


  def self.progress2
    {
      :"Assigned"         => {percentage: "25%"},
      :"Under Review"     => {percentage: "50%"},
      :"Pending Approval" => {percentage: "75%"},
      :"Completed"        => {percentage: "100%"},
    }
  end


  def get_progress
    self.class.progress2[status.to_sym][:percentage]
  end



  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    meta_fields = BaseConfig.get_sra_meta_fields
    meta_fields.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def get_source
    if self.record.present?
      "<a style='font-weight:bold' href='/records/#{self.record.id}'>
        Report ##{self.record.id}
      </a>".html_safe
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


  def create_transaction(action)
    Transaction.build_for(
      self,
      action,
      (session[:simulated_id] || session[:user_id])
    )
  end

  def approver_name
    self.approver.present? ? self.approver.full_name : ""
  end

  def reviewer_name
    self.reviewer.present? ? self.reviewer.full_name : ""
  end

  def manager_name
    self.responsible_user.present? ? self.responsible_user.full_name : ""
  end

  def need_approval
    self.reviewer.present? || self.approver.present?
  end

  def overdue
    self.scheduled_completion_date.present? ? self.scheduled_completion_date<Time.now.to_date&&self.status!="Completed" : false
  end
  def get_completion_date
    self.scheduled_completion_date.present? ? self.scheduled_completion_date.strftime("%Y-%m-%d") : ""
  end

  def load_departments
    if self.departments.present?
      self.departments
    else
      []
    end
  end
  def load_manuals
    if self.manuals.present?
      self.manuals
    else
      []
    end
  end
  def load_programs
    if self.programs.present?
      self.programs
    else
      []
    end
  end

  def load_compliances
    if self.compliances.present?
      self.compliances
    else
      []
    end
  end

  def all_programs
    (self.load_programs.push(self.other_program)).reject(&:empty?).join(", ")
  end

  def all_manuals
    (self.load_manuals.push(self.other_manual)).reject(&:empty?).join(", ")
  end

  def all_departments
    (self.load_departments.push(self.other_department)).reject(&:empty?).join(", ")
  end

  def all_compliances
    (self.load_compliances.push(self.other_compliance).reject(&:empty?).join(", "))
  end


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def self.get_avg_complete
    candidates = self.where("status=? and date_complete is not ? ", "Completed", nil)
    if candidates.present?
      sum = 0
      candidates.map{|x| sum += (x.date_complete - x.created_at.to_date).to_i}
      result = (sum.to_f / candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


  def release_controls
    self.hazards.each(&:release_controls)
  end


  def can_complete? current_user
    current_user_id = session[:simulated_id] || session[:user_id]
    self.status == 'Assigned' && (
      (current_user_id == self.responsible_user_id rescue false) ||
      current_user.admin? ||
      current_user.has_access('sras','admin'))
  end


  def can_approve? current_user
    current_user_id = session[:simulated_id] || session[:user_id]
    current_user_object_admin = (current_user.admin? || current_user.has_access('sras','admin'))
    case self.status
    when 'Pending Review'
      current_user_object_admin || (current_user_id == self.reviewer_id rescue false)
    when 'Pending Approval'
      current_user_object_admin || (current_user_id == self.approver_id rescue false)
    else
      false
    end
  end


  def can_reopen? current_user
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('sras','admin'))
  end

end
