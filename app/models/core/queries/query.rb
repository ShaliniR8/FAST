class Query < ActiveRecord::Base

  has_many :query_conditions, foreign_key: :query_id, class_name: 'QueryCondition', dependent: :destroy
  has_many :visualizations, foreign_key: :owner_id, class_name: 'QueryVisualization', dependent: :destroy
  belongs_to :created_by, foreign_key: :created_by_id, class_name: "User"

  serialize :templates, Array
  serialize :old_vis, Array

  accepts_nested_attributes_for :query_conditions


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',            title: 'ID',         num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'title',         title: 'Title',      num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'created_by',    title: 'Created By', num_cols: 12,  type: 'user', visible: 'index,show'},
      {field: 'get_target',    title: 'Target',     num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'get_templates', title: 'Templates',  num_cols: 12,  type: 'text', visible: 'show'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_target
    CONFIG.hierarchy.values.map{|x| x[:objects]}.compact.inject(:merge)[target][:title].pluralize
  end


  def get_templates
    if templates.present?
      Template.where(:id => templates).map(&:name).join(", ")
    else
      "N/A"
    end
  end


  def make_copy
    query = self.clone
    query.title = "Copy of #{query.title}"
    query.created_by_id = session[:user_id]
    query.query_conditions = []
    self.query_conditions.each do |condition|
      query.query_conditions << condition.make_copy
    end
    query.save
    query
  end


end
