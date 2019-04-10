class AddFieldsToEvaluations < ActiveRecord::Migration
  def self.up
    add_column :evaluations, :approver_poc_id, :integer
    add_column :evaluations, :evaluator_poc_id, :integer
  end

  def self.down
    remove_column :evaluations, :evaluator_poc_id
    remove_column :evaluations, :approver_poc_id
  end
end
