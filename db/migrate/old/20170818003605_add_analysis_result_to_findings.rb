class AddAnalysisResultToFindings < ActiveRecord::Migration
  def self.up
	add_column :findings, :analysis_result, :text
  end

  def self.down
	remove_column :findings, :analysis_result
  end
end
