class Query < ActiveRecord::Base

  include ApplicationHelper
  include Subscriptionable

  has_many :query_conditions, foreign_key: :query_id, class_name: 'QueryCondition', dependent: :destroy
  has_many :visualizations, foreign_key: :owner_id, class_name: 'QueryVisualization', dependent: :destroy
  belongs_to :created_by, foreign_key: :created_by_id, class_name: "User"

  serialize :templates, Array
  serialize :old_vis, Array
  serialize :distribution_list_ids, Array

  accepts_nested_attributes_for :query_conditions


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',             title: 'ID',         num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'title',          title: 'Title',      num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'distribution_list_ids',  title: 'Distribution List for Notification', num_cols: 12, type: 'select_multiple', visible: 'show,form', required: false,  options: get_distribution_list},
      {field: 'threshold',  title: 'Threshold', num_cols: 12, type: 'text', visible: 'show,form', required: false},
      {field: 'get_created_by', title: 'Created By', num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'get_target',     title: 'Target',     num_cols: 12,  type: 'text', visible: 'index,show'},
      {field: 'get_templates',  title: 'Templates',  num_cols: 12,  type: 'text', visible: 'show'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_target
    if session[:mode] == "OSHA"
      '(OSHA) Reports'
    else
      CONFIG.hierarchy[session[:mode]][:objects][target][:title].pluralize rescue ""
    end
  end


  def get_created_by
    created_by.present? ? created_by.full_name : ""
  end


  def to_csv
    visualization = self.visualizations.first
    records_ids = get_query_results_ids_helper(self.id)
    data = generate_visualization_helper(self.id, visualization.x_axis, visualization.series, records_ids)

    csv_data = CSV.generate(headers: false) do |csv|
      data.each do |row|
        csv << row
      end
    end

    csv_data
  end


  def get_templates
    if templates.present?
      if target == "Checklist"
        if templates.include? '-1'
          templates_id = templates.clone
          templates_id.delete('-1')
          Checklist.where(:id => templates_id).map(&:title).join(", ") + ', NO TEMPLATE'
        else
          Checklist.where(:id => templates).map(&:title).join(", ")
        end
      else
        Template.where(:id => templates).map(&:name).join(", ")
      end
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

  def self.get_distribution_list
    DistributionList.all.map{|d| [d.title, d.id]}
  end

  def set_threshold(params)
    self.threshold = params[:threshold]
    if params[:distros] == nil
      self.distribution_list_ids = nil
    else
      self.distribution_list_ids = params[:distros].map {|str| str.to_i}
    end
    self.save
  end


end
