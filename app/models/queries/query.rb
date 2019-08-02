class Query < ActiveRecord::Base

  has_many :query_conditions, foreign_key: :query_id, class_name: 'QueryCondition', dependent: :destroy
  belongs_to :created_by, foreign_key: :created_by_id, class_name: "User"

  serialize :visualizations, Array

  accepts_nested_attributes_for :query_conditions

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',            title: 'ID',         num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'title',         title: 'Title',      num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'created_by_id', title: 'Created By', num_cols: 12,  type: 'user', visible: 'index,show'},
      {field: 'get_target',    title: 'Target',     num_cols: 12,  type: 'text', visible: 'index,show'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def get_target
    BaseConfig::MODULES.values.map{|x| x[:objects]}.compact.inject(:merge)[target] ||
    Template.where(:id => target.split(",")).map(&:name).join(", ")
  end


end
