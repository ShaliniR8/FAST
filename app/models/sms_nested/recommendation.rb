class Recommendation < ActiveRecord::Base
  extend AnalyticsFilters
  include StandardWorkflow
  include GroupAccessHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Noticeable
  include Transactionable

#Associations List
  belongs_to :responsible_user,    foreign_key: 'responsible_user_id', class_name: 'User'
  belongs_to :approver,            foreign_key: 'approver_id',         class_name: 'User'
  belongs_to :created_by,          foreign_key: 'created_by_id',       class_name: 'User'
  belongs_to :owner,               polymorphic: true

  has_many :descriptions, foreign_key: 'owner_id', class_name: 'RecommendationDescription', dependent: :destroy

  after_create :create_transaction
  after_create :create_owner_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      { field: 'id',                            title: 'ID',                                num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      { field: 'status',                        title: 'Status',                            num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      { field: 'title',                         title: 'Title',                             num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      { field: 'get_source',                    title: 'Source of Input',                   num_cols: 6,  type: 'text',         visible: 'index,show',      required: false},
      {field: 'created_by_id',                  title: 'Created By',                        num_cols: 6,  type: 'user',         visible: 'show',            required: false},

      {                                                                                                   type: 'newline',      visible: 'show'},
      { field: 'response_date',                 title: 'Scheduled Response Date',           num_cols: 6,  type: 'date',         visible: 'index,form,show', required: true},
      {                                                                                                   type: 'newline',      visible: 'show'},
      { field: 'responsible_user_id',           title: 'Responsible User',                  num_cols: 6,  type: 'user',         visible: 'index,form,show', required: false},
      { field: 'approver_id',                   title: 'Final Approver',                    num_cols: 6,  type: 'user',         visible: 'form,show',       required: false},
      {                                                                                                   type: 'newline',      visible: 'form,show'},
      { field: 'department',                    title: 'Responsible Department',            num_cols: 6,  type: 'select',       visible: 'index,form,show', required: false,  options: get_custom_options('Departments')},
      {                                                                                                   type: 'newline',      visible: 'form,show'},
      { field: 'immediate_action',              title: 'Immediate Action Required',         num_cols: 6,  type: 'boolean_box',  visible: 'form,show',       required: false},
      {                                                                                                   type: 'newline',      visible: 'form'},
      { field: 'recommended_action',            title: 'Action',                            num_cols: 6,  type: 'datalist',     visible: 'index,form,show', required: false,  options: get_custom_options('Actions Taken')},
      { field: 'description',                   title: 'Description of Recommendation',     num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      { field: 'recommendations_comment',       title: 'Recommendation Comment',            num_cols: 12, type: 'textarea',     visible: 'form,show',       required: false},
      { field: 'final_comment',                 title: 'Final Comment',                     num_cols: 12, type: 'textarea',     visible: 'show',            required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_source
    "<b style='color:grey'>N/A</b>".html_safe
  end


  def self.progress
    {
      "New"               => { :score => 25,  :color => "default"},
      "Assigned"          => { :score => 50,  :color => "warning"},
      "Pending Approval"  => { :score => 75,  :color => "warning"},
      "Completed"         => { :score => 100, :color => "success"},
    }
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


  def can_assign?(user, form_conds: false, user_conds: false)
    super(user, form_conds: form_conds, user_conds: user_conds) &&
      (self.immediate_action || self.owner.status == 'Completed')
  end


  def get_responsible_user_name
    self.responsible_user.full_name rescue ''
  end


  def overdue
    self.response_date < Time.now.to_date && self.status != "Completed" rescue false
  end


  def self.get_avg_complete
    candidates = self.where("status = ? and complete_date is not ? and open_date is not ? ", "Completed", nil, nil)
    if candidates.present?
      sum = 0
      candidates.map{|x| sum += (x.complete_date - x.open_date).to_i}
      result = (sum.to_f / candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


  def get_source
    case owner.class.name
    when 'Investigation'
      "<a style='font-weight:bold' href='/investigations/#{owner.id}'>
        Investigation ##{owner.id}
      </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
    when 'Finding'
      "<a style='font-weight:bold' href='/findings/#{owner.id}'>
        Finding ##{owner.id}
      </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
    else
      "<b style='color:grey'>N/A</b>".html_safe
    end
  end


end
