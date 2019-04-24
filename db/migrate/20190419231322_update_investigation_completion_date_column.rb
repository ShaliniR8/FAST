class UpdateInvestigationCompletionDateColumn < ActiveRecord::Migration
  def self.up
    rename_column :investigations, :scheduled_completion_date, :completion
  end

  def self.down
    rename_column :investigations, :completion, :scheduled_completion_date
  end
end
