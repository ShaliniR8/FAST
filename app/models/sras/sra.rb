class Sra < ActiveRecord::Base
  extend AnalyticsFilters
  include StandardWorkflow
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

  after_create :create_transaction

  def self.progress
    {
      "New"                     => { :score => 0,   :color => "default"},
      "Assigned"                => { :score => 25,  :color => "default"},
      "Pending Review"          => { :score => 50,  :color => "warning"},
      "Pending Approval"        => { :score => 75,  :color => "warning"},
      "Completed"               => { :score => 100, :color => "success"},
    }
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


  def approver_name
    self.approver.present? ? self.approver.full_name : ""
  end


  def overdue
    self.scheduled_completion_date.present? ? self.scheduled_completion_date<Time.now.to_date&&self.status!="Completed" : false
  end


  def get_completion_date
    self.scheduled_completion_date.present? ? self.scheduled_completion_date.strftime("%Y-%m-%d") : ""
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


  def can_approve?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) || (
      self.status == 'Pending Review' && ( self.reviewer_id == user.id || has_admin_rights?(user) )
    )
  end


end
