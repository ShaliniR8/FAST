class AddFieldsToIms < ActiveRecord::Migration
  def self.up
    add_column :ims, :lead_evaluator_poc_id, :integer
    add_column :ims, :pre_reviewer_poc_id, :integer
    add_column :ims, :obj_id, :integer
  end

  def self.down
    remove_column :ims, :obj_id
    remove_column :ims, :pre_reviewer_poc_id
    remove_column :ims, :lead_evaludator_poc_id
  end
end
