class QueryCondition < ActiveRecord::Base


  belongs_to :query, foreign_key: :query_id, class_name: "Query"
  belongs_to :query_condition, foreign_key: :query_condition_id, class_name: "QueryCondition"

  has_many :query_conditions, foreign_key: :query_condition_id, class_name: 'QueryCondition', dependent: :destroy

  accepts_nested_attributes_for :query_conditions


  def get_logic() logic end
  def get_field_name() field_name end
  def get_value() value.present? ? value : "*Empty Value*" end

end
