class QueryStatement < ActiveRecord::Base
  has_many :query_conditions,foreign_key:"query_statement_id",class_name:"QueryCondition"
  belongs_to :owner,foreign_key:"user_id",class_name:"User"
  serialize :privileges
  accepts_nested_attributes_for :query_conditions, allow_destroy: true

  before_create :set_priveleges

  def self.get_headers
    [
      {:field => "id",                          :title => "ID"},
      {:field => "title",                       :title => "Title"},
      {:field => "num_of_conditions",           :title => 'Conditions'},
      # {:field => "records_count",               :title => 'Records'},
      # {:field => "created_by",                  :title => 'Created By'},
    ]
  end

  def records_count
    if query_conditions.present?
      result = []
      query_conditions.group_by{|x| x.template_id}.each_pair do |t, conditions|
        if target_class == "Submission"
          candidates = Submission.where("templates_id=? and completed = 1", t)
        else
          candidates = Record.where("templates_id=?", t)
        end
        result.concat(candidates.select{|x| x.satisfy(conditions)})
      end
      result.length
    else
      if target_class == "Submission"
        Submission.where(:completed => true).length
      else
        Record.find(:all).length
      end
    end
  end

  def num_of_conditions
    self.query_conditions.length
  end

  def get_privileges
    self.privileges.present? ?  self.privileges : []
  end

  def is_visualize
    self.visualize? ? "Yes" : "No"
  end

  def set_priveleges
    if self.privileges.blank?
      self.privileges = []
    end
  end

  def created_by
    self.owner.full_name
  end

  def duplicate
    new_query = self.clone
    new_query.query_conditions << self.query_conditions.collect { |c| c.clone }
    new_query.title=new_query.title+"--Copy"
    new_query.save
    new_query
  end
end
