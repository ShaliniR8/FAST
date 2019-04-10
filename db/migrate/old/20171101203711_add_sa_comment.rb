class AddSaComment < ActiveRecord::Migration
  def self.up
	add_column :inspections, :inspector_comment, :text
	add_column :evaluations, :evaluator_comment, :text
	add_column :investigations, :investigator_comment, :text
	add_column :findings, :findings_comment, :text
	add_column :sms_actions, :sms_actions_comment, :text
	add_column :recommendations, :recommendations_comment, :text
  end

  def self.down
	remove_column :inspections, :inspector_comment
	remove_column :evaluations, :evaluator_comment
	remove_column :investigations, :investigator_comment
	remove_column :findings, :findings_comment
    remove_column :sms_actions, :sms_actions_comment
    remove_column :recommendations, :recommendations_comment
  end
end
