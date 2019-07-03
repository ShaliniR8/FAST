class Sra < ActiveRecord::Base

  has_many :attachments,              :foreign_key => "owner_id",   :class_name => "SraAttachment",       :dependent => :destroy
  has_many :hazards,                  :foreign_key => "sra_id",     :class_name => "Hazard",              :dependent => :destroy
  has_many :transactions,             :foreign_key => "owner_id",   :class_name => "SraTransaction",      :dependent => :destroy
  has_many :srm_agendas,              :foreign_key => "event_id",   :class_name => "SrmAgenda",           :dependent => :destroy
  has_many :notices,                  :foreign_key => "owner_id",   :class_name => "SraNotice",           :dependent => :destroy
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
  serialize :severity_extra
  serialize :probability_extra
  serialize :mitigated_severity
  serialize :mitigated_probability

  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank?&&attachment[:_destroy].blank?)}
  accepts_nested_attributes_for :hazards


  before_create :set_extra
  after_create -> { create_transaction('Create') }

  extend AnalyticsFilters


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
    return [
      { field: "get_id",                    title: "ID",                                       num_cols: 6,   type: "text",        visible: 'index,show',        required: false},
      { field: "status",                    title: "Status",                                   num_cols: 6,   type: "text",        visible: 'index,show',        required: false},
      {                                                                                                       type: "newline",     visible: 'form,show'},
      { field: "title",                     title: "SRA Title",                                num_cols: 6,   type: "text",        visible: 'index,form,show',   required: false},
      { field: "type_of_change",            title: "Type of Change",                           num_cols: 6,   type: "datalist",    visible: 'index,form,show',   required: false, options: get_custom_options('SRA Type of Change')},
      { field: "system_task",               title: "System/Task",                              num_cols: 6,   type: "datalist",    visible: 'index,form,show',   required: false, options: get_custom_options('Systems/Tasks')},
      { field: "responsible_user_id",       title: "Responsible User",                         num_cols: 6,   type: "user",        visible: 'index,form,show',  required: false},
      { field: "reviewer_id",               title: "Quality Reviewer",                         num_cols: 6,   type: "user",        visible: 'form,show',         required: false},
      { field: "approver_id",               title: "Final Approver",                           num_cols: 6,   type: "user",        visible: 'form,show',         required: false},
      { field: "scheduled_completion_date", title: "Scheduled Completion Date",                num_cols: 6,   type: "date",        visible: 'index,form,show',   required: false},
      { field: "current_description",       title: "Describe the Current System",              num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      { field: "plan_description",          title: "Describe Proposed Plan",                   num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                     title: "Affected Department",                      num_cols: 12,  type: "panel_start", visible: 'form,show'},
      { field: "departments",               title: "Affected Departments",                     num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: get_custom_options('Departments')},
      { field: "other_department",          title: "Other Affected Departments",               num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "departments_comment",       title: "Affected Departments Comments",            num_cols: 12,  type: "textarea",    visible: 'form,show',        required: false},
      {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      {                                     title: "Affected Programs",                        num_cols: 12,  type: "panel_start", visible: 'form,show'},
      { field: "programs",                  title: "Affected Programs",                        num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: get_custom_options('Programs')},
      { field: "other_program",             title: "Other Affected Programs",                  num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "programs_comment",          title: "Affected Programs Comments",               num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      {                                     title: "Affected Manuals",                         num_cols: 12,  type: "panel_start", visible: 'form,show'},
      { field: "manuals",                   title: "Affected Manuals",                         num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: get_custom_options('Manuals')},
      { field: "other_manual",              title: "Other Affected Manuals",                   num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "manuals_comment",           title: "Affected Manuals Comments",                num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      {                                     title: "Affected #{Sra.sra_section_4}",           num_cols: 12,  type: "panel_start", visible: 'form,show',},
      { field: "compliances",               title: "Affected #{Sra.sra_section_4}",           num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: get_custom_options("#{Sra.sra_section_4}")},
      { field: "other_compliance",          title: "Other Affected #{Sra.sra_section_4}",     num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "compliances_comment",       title: "Affected #{Sra.sra_section_4} Comments",  num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                                                                       num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      { field: "closing_comment",           title: "Responsible User's Closing Comments",      num_cols: 12,  type: "text",        visible: 'show'},
      { field: "reviewer_comment",          title: "Quality Reviewer's Closing Comments",      num_cols: 12,  type: "text",        visible: 'show'},
      { field: "approver_comment",          title: "Final Approver's Closing Comments",        num_cols: 12,  type: "text",        visible: 'show'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.sra_section_4
    if BaseConfig.airline_code == 'BSK'
      'System Task Analysis SHEL(L) Models'
    else
      'Regulatory Compliances'
    end
  end


  def self.get_custom_options(title)
    CustomOption
      .where(:title => title)
      .first
      .options
      .split(';') rescue ['Please go to Custom Options to add options.']
  end


  def set_extra
    if self.severity_extra.blank?
      self.severity_extra=[]
    end
    if self.severity_extra.blank?
      self.probability_extra=[]
    end
    if self.mitigated_severity.blank?
      self.mitigated_severity=[]
    end
    if self.mitigated_probability.blank?
      self.mitigated_probability=[]
    end
  end

  def get_extra_severity
    self.severity_extra.present? ?  self.severity_extra : []
  end

  def get_extra_probability
    self.probability_extra.present? ?  self.probability_extra : []
  end
  def get_mitigated_probability
    self.mitigated_probability.present? ?  self.mitigated_probability : []
  end
  def get_mitigated_severity
    self.mitigated_severity.present? ?  self.mitigated_severity : []
  end
  def create_transaction(action)
    SraTransaction.create(:users_id=>session[:user_id],:action=>action,:owner_id=>self.id,:stamp=>Time.now)
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




  def get_before_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_before_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index].index(display_before_risk_factor)
    end
  end

  def get_after_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_after_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index].index(display_after_risk_factor)
    end
  end

  def display_before_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity
    else
      get_risk_values[:severity_1].present? ? get_risk_values[:severity_1] : "N/A"
    end
  end

  def display_before_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood
    else
      get_risk_values[:probability_1].present? ? get_risk_values[:probability_1] : "N/A"
    end
  end

  def display_before_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor.present? ? risk_factor : "N/A"
    else
      get_risk_values[:risk_1].present? ? get_risk_values[:risk_1] : "N/A"
    end
  end

  def display_after_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity_after
    else
      get_risk_values[:severity_2].present? ? get_risk_values[:severity_2] : "N/A"
    end
  end

  def display_after_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood_after
    else
      get_risk_values[:probability_2].present? ? get_risk_values[:probability_2] : "N/A"
    end
  end

  def display_after_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor_after.present? ? risk_factor_after : "N/A"
    else
      get_risk_values[:risk_2].present? ? get_risk_values[:risk_2] : "N/A"
    end
  end

  def get_risk_values
    airport_config = Object.const_get("#{BaseConfig.airline[:code]}_Config")
    matrix_config = airport_config::MATRIX_INFO
    @severity_table = matrix_config[:severity_table]
    @probability_table = matrix_config[:probability_table]
    @risk_table = matrix_config[:risk_table]

    @severity_score = airport_config.calculate_severity(severity_extra)
    @sub_severity_score = airport_config.calculate_severity(mitigated_severity)
    @probability_score = airport_config.calculate_severity(probability_extra)
    @sub_probability_score = airport_config.calculate_severity(mitigated_probability)

    @print_severity = airport_config.print_severity(self, @severity_score)
    @print_probability = airport_config.print_probability(self, @probability_score)
    @print_risk = airport_config.print_risk(@probability_score, @severity_score)

    @print_sub_severity = airport_config.print_severity(self, @sub_severity_score)
    @print_sub_probability = airport_config.print_probability(self, @sub_probability_score)
    @print_sub_risk = airport_config.print_risk(@sub_probability_score, @sub_severity_score)

    {
      :severity_1       => @print_severity,
      :severity_2       => @print_sub_severity,
      :probability_1    => @print_probability,
      :probability_2    => @print_sub_probability,
      :risk_1           => @print_risk,
      :risk_2           => @print_sub_risk,
    }
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

  def self.get_likelihood
    ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"]
  end


  def likelihood_after_index
    if BaseConfig.airline[:base_risk_matrix]
      self.class.get_likelihood.index(self.likelihood_after).to_i
    else
      self.likelihood_after.to_i
    end
  end


  def likelihood_index
    if BaseConfig.airline[:base_risk_matrix]
      self.class.get_likelihood.index(self.likelihood).to_i
    else
      self.likelihood.to_i
    end
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
